from collections import defaultdict

def parse_obj(filepath):
    positions = []
    normals = []
    uvs = []
    groups = [] 

    current_material = None
    current_triangles = []

    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue

            parts = line.split()
            keyword = parts[0]

            if keyword == 'v':
                positions.append([float(x) for x in parts[1:4]])
            elif keyword == 'vt':
                uvs.append([float(x) for x in parts[1:3]])
            elif keyword == 'vn':
                normals.append([float(x) for x in parts[1:4]])
            elif keyword == 'usemtl':
                if current_triangles:
                    groups.append((current_material, current_triangles))
                current_material = parts[1]
                current_triangles = []
            elif keyword == 'f':
                v0, v1, v2 = parts[1], parts[2], parts[3]

                def parse_vertex(v):
                    indices = v.split('/')
                    pos_i = int(indices[0]) - 1
                    uv_i = int(indices[1]) - 1 if len(indices) > 1 and indices[1] else None
                    nor_i = int(indices[2]) - 1 if len(indices) > 2 and indices[2] else None

                    return (pos_i, uv_i, nor_i)

                triangle = (parse_vertex(v0), parse_vertex(v1), parse_vertex(v2))
                current_triangles.append(triangle)

    if current_triangles:
        groups.append((current_material, current_triangles))

    return positions, normals, uvs, groups


def build_meshes(positions, normals, uvs, groups):
    meshes = []

    for material, triangles in groups:
        hashmap = {}
        vertices = []
        indices = []

        for triangle in triangles:
            for (pos_i, uv_i, nor_i) in triangle:
                position = tuple(positions[pos_i])
                uv = tuple(uvs[uv_i]) if uv_i is not None else (0.0, 0.0)
                normal = tuple(normals[nor_i]) if nor_i is not None else (0.0, 0.0, 0.0)

                vertex = position + uv + normal

                i = hashmap.get(vertex)

                if i is None:
                    i = len(vertices)
                    hashmap[vertex] = i
                    vertices.append(vertex)

                indices.append(i)


        # create mesh
        # create renderer by doing materials.get(material)
        meshes.append((material, vertices, indices))

    return meshes

if __name__ == "__main__":
    positions, normals, uvs, groups = parse_obj('assets/car.obj')
    meshes = build_meshes(positions, normals, uvs, groups)
    for material, vertices, indices in meshes:
        print(f"Material: {material}")
        print(f"Triangles: {len(indices) // 3}")
        print(f"Vertices: {len(vertices)}")
        print(f"Indices: {len(indices)}")
        print()
