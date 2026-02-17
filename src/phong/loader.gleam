import fluo/color
import fluo/mesh.{type Vec2, type Vec3}
import fluo/texture
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import phong/model.{type PhongMaterial, PhongMaterial}
import shared/transform
import simplifile

type Obj {
  Obj(
    positions: Dict(Int, Vec3),
    normals: Dict(Int, Vec3),
    uvs: Dict(Int, Vec2),
    faces: List(ObjFace),
    mtllib: String,
  )
}

type ObjFace {
  ObjFace(material: String, triangles: List(#(Int, Int, Int)))
}

type ObjMesh {
  ObjMesh(
    material: String,
    vertices_count: Int,
    indices_count: Int,
    vertices: BitArray,
    indices: BitArray,
  )
}

pub fn load(transform: transform.Transform, path: String) -> model.PhongModel {
  let obj = load_obj(path)

  let mesh = load_meshes(obj)

  let materials = load_materials(obj, dict.new(), dict.new())

  let vertices_count =
    list.fold(mesh, 0, fn(acc, obj) { acc + obj.vertices_count })

  let indices_count =
    list.fold(mesh, 0, fn(acc, obj) { acc + obj.indices_count })

  let drawables =
    mesh.create_many(vertices_count, indices_count, load_drawables(
      _,
      mesh,
      materials,
    ))

  model.PhongModel(drawables, transform)
}

fn load_drawables(
  allocate: mesh.Allocator,
  meshes: List(ObjMesh),
  materials: Dict(String, PhongMaterial),
) -> List(model.Drawable) {
  use obj <- list.map(meshes)

  let ObjMesh(material:, vertices:, indices:, ..) = obj

  let assert Ok(material) = dict.get(materials, material)
    as { "Material not found: " <> material }

  let renderer = model.create_phong_renderer(material)

  let mesh = allocate(vertices, indices)

  model.Drawable(mesh, renderer)
}

fn load_materials(
  obj: Obj,
  materials: Dict(String, PhongMaterial),
  textures: Dict(String, texture.Texture),
) -> Dict(String, PhongMaterial) {
  let assert Ok(content) = simplifile.read(obj.mtllib)
    as "Failed to read MTL file"

  let assert [_, ..chunks] = string.split(content, "newmtl ")
    as "Failed to parse MTL file"

  let default_mat = model.create_default_material()

  use mats, chunk <- list.fold(chunks, materials)

  let assert [name, ..prop_lines] = string.split(chunk, "\n")
    as "Failed to parse MTL chunk"

  let mat = {
    use mat, line <- list.fold(prop_lines, default_mat)

    case string.trim(line) {
      "Ka " <> rest -> PhongMaterial(..mat, ambient: parse_color(rest))
      "Kd " <> rest -> PhongMaterial(..mat, diffuse: parse_color(rest))
      "Ks " <> rest -> PhongMaterial(..mat, specular: parse_color(rest))
      "Ke " <> rest -> PhongMaterial(..mat, emissive: parse_color(rest))
      "illum " <> rest -> PhongMaterial(..mat, illum: parse_int(rest))
      "Ns " <> rest -> PhongMaterial(..mat, shininess: parse_float(rest))
      "d " <> rest -> PhongMaterial(..mat, dissolve: parse_float(rest))
      "Tf " <> rest ->
        PhongMaterial(..mat, transmission_filter: parse_color(rest))
      _ -> mat
    }
  }

  dict.insert(mats, string.trim(name), mat)
}

fn load_meshes(obj: Obj) -> List(ObjMesh) {
  let Obj(faces:, positions:, normals:, uvs:, ..) = obj

  use ObjFace(triangles:, material:) <- list.map(faces)

  let vertices = {
    use #(position, uv, normal) <- list.map(triangles)

    let assert Ok(position) = dict.get(positions, position)
      as { "Position index not found: " <> int.to_string(position) }

    let uv = result.unwrap(dict.get(uvs, uv), mesh.Vec2(0.0, 0.0))

    let normal =
      result.unwrap(dict.get(normals, normal), mesh.Vec3(0.0, 0.0, 0.0))

    mesh.Vertex(position:, uv:, normal:)
  }

  let hashmap =
    list.fold(vertices, dict.new(), fn(hashmap, vertex) {
      case dict.has_key(hashmap, vertex) {
        True -> hashmap
        False -> dict.insert(hashmap, vertex, dict.size(hashmap))
      }
    })

  let indices =
    list.map(vertices, fn(vertex) {
      let assert Ok(index) = dict.get(hashmap, vertex)
      index
    })

  let vertices =
    dict.to_list(hashmap)
    |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
    |> list.map(fn(pair) { pair.0 })

  let vertices_count = list.length(vertices)
  let indices_count = list.length(indices)

  let vertices = mesh.vertices_to_bitarray(vertices)
  let indices = mesh.indices_to_bitarray(indices)

  ObjMesh(material, vertices_count, indices_count, vertices, indices)
}

fn load_obj(path: String) -> Obj {
  let assert Ok(content) = simplifile.read(path) as "Failed to read OBJ file"

  let lines = string.split(content, "\n")

  let dir =
    path
    |> string.split("/")
    |> list.reverse()
    |> list.drop(1)
    |> list.reverse()
    |> string.join("/")

  let initial =
    Obj(
      positions: dict.new(),
      normals: dict.new(),
      uvs: dict.new(),
      mtllib: "",
      faces: [],
    )

  use state, line <- list.fold(lines, initial)

  case line {
    "" -> state
    "#" <> _ -> state

    "v " <> rest -> {
      let idx = dict.size(state.positions) + 1
      let position = parse_vec3(rest)
      let positions = dict.insert(state.positions, idx, position)

      Obj(..state, positions:)
    }

    "vn " <> rest -> {
      let idx = dict.size(state.normals) + 1
      let normal = parse_vec3(rest)
      let normals = dict.insert(state.normals, idx, normal)

      Obj(..state, normals:)
    }

    "vt " <> rest -> {
      let idx = dict.size(state.uvs) + 1
      let uv = parse_vec2(rest)
      let uvs = dict.insert(state.uvs, idx, uv)

      Obj(..state, uvs:)
    }

    "f " <> rest -> {
      let assert [face, ..others] = state.faces as "Failed to parse face"

      let parse = fn(i) { int.parse(i) |> result.unwrap(0) }

      let triangles =
        rest
        |> string.trim
        |> string.split(" ")
        |> list.filter(fn(v) { v != "" })
        |> list.map(fn(v) {
          case string.split(v, "/") {
            [pos] -> #(parse(pos), 0, 0)
            [pos, uv] -> #(parse(pos), parse(uv), 0)
            [pos, uv, nor, ..] -> #(parse(pos), parse(uv), parse(nor))
            _ -> panic as "Invalid vertex"
          }
        })
        |> fn(verts) {
          case verts {
            [v0, v1, v2] -> [v0, v1, v2]
            [v0, v1, v2, v3] -> [v0, v1, v2, v0, v2, v3]
            _ -> []
          }
        }

      let triangles = list.append(face.triangles, triangles)

      let face = ObjFace(..face, triangles:)

      Obj(..state, faces: [face, ..others])
    }

    "usemtl " <> material -> {
      let face = string.trim(material) |> ObjFace([])

      Obj(..state, faces: [face, ..state.faces])
    }

    "mtllib " <> rest -> Obj(..state, mtllib: dir <> "/" <> string.trim(rest))
    _ -> state
  }
}

fn parse_int(s: String) -> Int {
  let assert Ok(i) = int.parse(s) as { "Failed to parse int: " <> s }
  i
}

fn parse_float(s: String) -> Float {
  result.lazy_unwrap(float.parse(s), fn() {
    let assert Ok(i) = int.parse(s) as { "Failed to parse float: " <> s }
    int.to_float(i)
  })
}

fn parse_vec3(s: String) -> Vec3 {
  case string.split(string.trim(s), " ") {
    [x, y, z, ..] -> {
      let x = parse_float(x)
      let y = parse_float(y)
      let z = parse_float(z)

      mesh.Vec3(x, y, z)
    }
    _ -> panic as "Failed to parse Vec3"
  }
}

fn parse_vec2(s: String) -> Vec2 {
  case string.split(string.trim(s), " ") {
    [x, y, ..] -> {
      let x = parse_float(x)
      let y = parse_float(y)

      mesh.Vec2(x, y)
    }
    _ -> panic as "Failed to parse Vec2"
  }
}

fn parse_color(s: String) -> color.Color {
  let vec = parse_vec3(s)
  color.Color(vec.x, vec.y, vec.z)
}
