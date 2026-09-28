"""Bake abandonment into the Room 01 lounge.

Wood repeats in a Tile UV. Dirt is object-space, so it does not tile.
The bake is written into a unique UV, then that image is the only color
the glTF export keeps. wood_plank.png is a palm-tile photo, not boards,
and thatch.png is a hut photograph. Neither is used here.
"""
from __future__ import annotations

import math
import sys

import bpy

WOOD = "/home/chriswinters/palm-atoll/art/seasons/paloma/wood.png"
PAPER = "/home/chriswinters/palm-atoll/art/seasons/paloma/wallpaper_lounge.png"
BLEND = "/home/chriswinters/palm-atoll/tools/abandoned_lounge.blend"
GLB = "/home/chriswinters/palm-atoll/art/models/abandoned_lounge.glb"

EXTRA = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
ONLY = EXTRA[0] if EXTRA else ""


def bsdf(mat):
    return next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")


def mix_rgba(nt, blend, fac, color_a, color_b):
    mix = nt.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.blend_type = blend
    if isinstance(fac, (int, float)):
        mix.inputs[0].default_value = float(fac)
    else:
        nt.links.new(fac, mix.inputs[0])
    if isinstance(color_a, tuple):
        mix.inputs[6].default_value = color_a
    else:
        nt.links.new(color_a, mix.inputs[6])
    if isinstance(color_b, tuple):
        mix.inputs[7].default_value = color_b
    else:
        nt.links.new(color_b, mix.inputs[7])
    return mix.outputs[2]


def math_op(nt, op, a=None, b=None, a_val=None, b_val=None):
    node = nt.nodes.new("ShaderNodeMath")
    node.operation = op
    if a_val is not None:
        node.inputs[0].default_value = a_val
    if b_val is not None:
        node.inputs[1].default_value = b_val
    if a is not None:
        nt.links.new(a, node.inputs[0])
    if b is not None:
        nt.links.new(b, node.inputs[1])
    return node.outputs["Value"]


def noise_fac(nt, scale, detail, distortion, vector):
    node = nt.nodes.new("ShaderNodeTexNoise")
    node.inputs["Scale"].default_value = scale
    node.inputs["Detail"].default_value = detail
    node.inputs["Roughness"].default_value = 0.55
    node.inputs["Distortion"].default_value = distortion
    nt.links.new(vector, node.inputs["Vector"])
    return node.outputs["Fac"]


def fresh(name, rough, metal=0.0):
    old = bpy.data.materials.get(name)
    if old is not None:
        old.name = name + "_retired"
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    node = bsdf(mat)
    node.inputs["Roughness"].default_value = rough
    if "Metallic" in node.inputs:
        node.inputs["Metallic"].default_value = metal
    if "Specular IOR Level" in node.inputs:
        node.inputs["Specular IOR Level"].default_value = 0.25
    return mat


def pack_bake_uv(obj):
    mesh = obj.data
    while mesh.uv_layers:
        mesh.uv_layers.remove(mesh.uv_layers[0])
    uv = mesh.uv_layers.new(name="UVMap")
    faces = []
    for poly in mesh.polygons:
        normal = poly.normal
        axis = max(range(3), key=lambda i: abs(normal[i]))
        other = [i for i in range(3) if i != axis]
        coords = []
        for li in poly.loop_indices:
            co = mesh.vertices[mesh.loops[li].vertex_index].co
            coords.append((co[other[0]], co[other[1]], li))
        xs = [c[0] for c in coords]
        ys = [c[1] for c in coords]
        min_x, max_x = min(xs), max(xs)
        min_y, max_y = min(ys), max(ys)
        width = max(max_x - min_x, 1e-4)
        height = max(max_y - min_y, 1e-4)
        faces.append((height, width, height, min_x, min_y, coords))
    total = sum(width * height for _, width, height, *_ in faces) or 1.0
    scale = math.sqrt(1.0 / (total * 1.55))
    faces.sort(key=lambda face: -face[0])
    margin = 0.015
    cursor_x = margin
    cursor_y = margin
    row_h = 0.0
    for _, width, height, min_x, min_y, coords in faces:
        packed_w = width * scale
        packed_h = height * scale
        if cursor_x + packed_w + margin > 1.0:
            cursor_x = margin
            cursor_y += row_h + margin
            row_h = 0.0
        row_h = max(row_h, packed_h)
        for co_a, co_b, li in coords:
            uv.data[li].uv = (
                cursor_x + (co_a - min_x) * scale,
                cursor_y + (co_b - min_y) * scale,
            )
        cursor_x += packed_w + margin
    peak = 0.0
    for datum in uv.data:
        peak = max(peak, datum.uv.x, datum.uv.y)
    if peak > 0.985:
        factor = 0.98 / peak
        for datum in uv.data:
            datum.uv.x *= factor
            datum.uv.y *= factor
    uv.active = True
    uv.active_render = True
    return uv


def write_tile_uv(obj, scale_u, scale_v, cylindrical=False):
    mesh = obj.data
    if "Tile" in mesh.uv_layers:
        mesh.uv_layers.remove(mesh.uv_layers["Tile"])
    tile = mesh.uv_layers.new(name="Tile")
    for poly in mesh.polygons:
        normal = poly.normal
        for li in poly.loop_indices:
            co = mesh.vertices[mesh.loops[li].vertex_index].co
            if cylindrical and abs(normal.z) < 0.65:
                u = math.atan2(co.y, co.x) / math.tau * scale_u
                v = co.z * scale_v
            elif abs(normal.z) >= abs(normal.x) and abs(normal.z) >= abs(normal.y):
                u, v = co.x * scale_u, co.y * scale_v
            elif abs(normal.x) >= abs(normal.y):
                u, v = co.y * scale_u, co.z * scale_v
            else:
                u, v = co.x * scale_u, co.z * scale_v
            tile.data[li].uv = (u, v)
    mesh.uv_layers["UVMap"].active = True
    mesh.uv_layers["UVMap"].active_render = True


def image_on_tile(nt, path):
    uv = nt.nodes.new("ShaderNodeUVMap")
    uv.uv_map = "Tile"
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(path, check_existing=True)
    tex.extension = "REPEAT"
    tex.interpolation = "Linear"
    nt.links.new(uv.outputs["UV"], tex.inputs["Vector"])
    return tex.outputs["Color"]


def object_vector(nt):
    coord = nt.nodes.new("ShaderNodeTexCoord")
    return coord.outputs["Object"]


def separate(nt, vector):
    node = nt.nodes.new("ShaderNodeSeparateXYZ")
    nt.links.new(vector, node.inputs["Vector"])
    return node.outputs["X"], node.outputs["Y"], node.outputs["Z"]


def dirt_profile(nt, vector, profile):
    x, y, z = separate(nt, vector)
    large = noise_fac(nt, 0.85, 6.0, 0.35, vector)
    fine = noise_fac(nt, 4.5, 4.0, 0.15, vector)
    blotch = math_op(nt, "SUBTRACT", large, b_val=0.52)
    blotch = math_op(nt, "MULTIPLY", blotch, b_val=2.6)
    blotch = math_op(nt, "MAXIMUM", blotch, b_val=0.0)
    blotch = math_op(nt, "MINIMUM", blotch, b_val=1.0)
    if profile == "floor":
        ax = math_op(nt, "ABSOLUTE", x)
        ay = math_op(nt, "ABSOLUTE", y)
        ax = math_op(nt, "DIVIDE", ax, b_val=7.0)
        ay = math_op(nt, "DIVIDE", ay, b_val=5.0)
        edge = math_op(nt, "MAXIMUM", ax, ay)
        edge = math_op(nt, "POWER", edge, b_val=1.35)
        # Bar and hall door sit on local -Y. Dirt banks up there.
        near = math_op(nt, "MULTIPLY", y, b_val=-1.0)
        near = math_op(nt, "SUBTRACT", near, b_val=2.4)
        near = math_op(nt, "DIVIDE", near, b_val=2.2)
        near = math_op(nt, "MAXIMUM", near, b_val=0.0)
        near = math_op(nt, "MINIMUM", near, b_val=1.0)
        factor = math_op(nt, "MULTIPLY", edge, b_val=0.62)
        near_scaled = math_op(nt, "MULTIPLY", near, b_val=0.48)
        factor = math_op(nt, "ADD", factor, near_scaled)
        blotch_scaled = math_op(nt, "MULTIPLY", blotch, b_val=0.28)
        factor = math_op(nt, "ADD", factor, blotch_scaled)
        stain = noise_fac(nt, 0.55, 2.0, 0.2, vector)
        stain = math_op(nt, "SUBTRACT", stain, b_val=0.46)
        stain = math_op(nt, "MULTIPLY", stain, b_val=5.0)
        stain = math_op(nt, "MAXIMUM", stain, b_val=0.0)
        stain = math_op(nt, "MINIMUM", stain, b_val=1.0)
        fine_scaled = math_op(nt, "MULTIPLY", fine, b_val=0.1)
        factor = math_op(nt, "ADD", factor, fine_scaled)
        stain_scaled = math_op(nt, "MULTIPLY", stain, b_val=0.92)
        factor = math_op(nt, "ADD", factor, stain_scaled)
        factor = math_op(nt, "ADD", factor, b_val=0.14)
    elif profile == "wall":
        # Local Z is the wall height, centred.
        low = math_op(nt, "MULTIPLY", z, b_val=-1.0)
        low = math_op(nt, "SUBTRACT", low, b_val=0.35)
        low = math_op(nt, "DIVIDE", low, b_val=0.85)
        low = math_op(nt, "MAXIMUM", low, b_val=0.0)
        low = math_op(nt, "MINIMUM", low, b_val=1.0)
        high = math_op(nt, "SUBTRACT", z, b_val=0.85)
        high = math_op(nt, "DIVIDE", high, b_val=0.5)
        high = math_op(nt, "MAXIMUM", high, b_val=0.0)
        high = math_op(nt, "MINIMUM", high, b_val=1.0)
        factor = math_op(nt, "MULTIPLY", low, b_val=0.72)
        high_scaled = math_op(nt, "MULTIPLY", high, b_val=0.16)
        factor = math_op(nt, "ADD", factor, high_scaled)
        blotch_scaled = math_op(nt, "MULTIPLY", blotch, b_val=0.48)
        factor = math_op(nt, "ADD", factor, blotch_scaled)
        factor = math_op(nt, "ADD", factor, b_val=0.16)
    elif profile == "counter":
        factor = math_op(nt, "MULTIPLY", blotch, b_val=0.55)
        fine_scaled = math_op(nt, "MULTIPLY", fine, b_val=0.14)
        factor = math_op(nt, "ADD", factor, fine_scaled)
        factor = math_op(nt, "ADD", factor, b_val=0.32)
    elif profile == "base":
        # Heavier toward the bottom of a vertical piece.
        low = math_op(nt, "MULTIPLY", z, b_val=-1.0)
        low = math_op(nt, "ADD", low, b_val=0.2)
        low = math_op(nt, "MAXIMUM", low, b_val=0.0)
        low = math_op(nt, "MINIMUM", low, b_val=1.0)
        factor = math_op(nt, "MULTIPLY", low, b_val=0.45)
        blotch_scaled = math_op(nt, "MULTIPLY", blotch, b_val=0.5)
        factor = math_op(nt, "ADD", factor, blotch_scaled)
        factor = math_op(nt, "ADD", factor, b_val=0.28)
    else:
        factor = math_op(nt, "MULTIPLY", blotch, b_val=0.34)
        fine_scaled = math_op(nt, "MULTIPLY", fine, b_val=0.1)
        factor = math_op(nt, "ADD", factor, fine_scaled)
        factor = math_op(nt, "ADD", factor, b_val=0.18)
    factor = math_op(nt, "MINIMUM", factor, b_val=0.86)
    factor = math_op(nt, "MAXIMUM", factor, b_val=0.0)
    return factor


def finish_shader(mat, color_socket, rough, metal):
    node = bsdf(mat)
    base = node.inputs["Base Color"]
    for link in list(base.links):
        mat.node_tree.links.remove(link)
    mat.node_tree.links.new(color_socket, base)
    node.inputs["Roughness"].default_value = rough
    if "Metallic" in node.inputs:
        node.inputs["Metallic"].default_value = metal


def build_surface(obj, kind, params):
    mat = fresh(f"Worn_{obj.name}", params["rough"], params.get("metal", 0.0))
    obj.material_slots[0].material = mat
    nt = mat.node_tree
    vector = object_vector(nt)
    if kind == "wood":
        write_tile_uv(obj, params["su"], params["sv"], params.get("cyl", False))
        color = image_on_tile(nt, WOOD)
        grade = nt.nodes.new("ShaderNodeBrightContrast")
        # Contrast here is added to 1. 0.2 is a small lift. 20 clips the wood to pure red.
        grade.inputs["Bright"].default_value = params.get("bright", -0.02)
        grade.inputs["Contrast"].default_value = params.get("contrast", 0.18)
        nt.links.new(color, grade.inputs["Color"])
        color = grade.outputs["Color"]
        sat = nt.nodes.new("ShaderNodeHueSaturation")
        sat.inputs["Saturation"].default_value = params.get("sat", 0.42)
        sat.inputs["Value"].default_value = params.get("value", 0.72)
        nt.links.new(color, sat.inputs["Color"])
        color = sat.outputs["Color"]
        color = mix_rgba(nt, "MULTIPLY", 1.0, color, (*params["age"], 1.0))
    elif kind == "paper":
        write_tile_uv(obj, params["su"], params["sv"], False)
        color = image_on_tile(nt, PAPER)
        color = mix_rgba(nt, "MULTIPLY", 1.0, color, (*params["age"], 1.0))
    elif kind == "thatch":
        straw = noise_fac(nt, 9.0, 10.0, 0.4, vector)
        band = noise_fac(nt, 2.2, 3.0, 0.2, vector)
        color = mix_rgba(nt, "MIX", straw, (0.28, 0.18, 0.08, 1), (0.52, 0.36, 0.16, 1))
        color = mix_rgba(nt, "MULTIPLY", band, color, (0.55, 0.48, 0.36, 1))
    elif kind == "fabric":
        nap = noise_fac(nt, 6.0, 8.0, 0.2, vector)
        color = mix_rgba(nt, "MIX", nap, (0.16, 0.07, 0.06, 1), (0.34, 0.18, 0.13, 1))
    elif kind == "brass":
        speckle = noise_fac(nt, 7.0, 6.0, 0.5, vector)
        color = mix_rgba(nt, "MIX", speckle, (0.18, 0.12, 0.05, 1), (0.55, 0.38, 0.14, 1))
    elif kind == "iron":
        speckle = noise_fac(nt, 5.5, 6.0, 0.45, vector)
        color = mix_rgba(nt, "MIX", speckle, (0.08, 0.07, 0.06, 1), (0.28, 0.26, 0.22, 1))
    elif kind == "book":
        color = mix_rgba(nt, "MIX", 0.0, (0.34, 0.2, 0.1, 1), (0.34, 0.2, 0.1, 1))
    else:
        raise RuntimeError(kind)
    factor = dirt_profile(nt, vector, params.get("profile", "general"))
    grime = (*params.get("dirt", (0.06, 0.045, 0.03)), 1.0)
    color = mix_rgba(nt, "MIX", factor, color, grime)
    finish_shader(mat, color, params["rough"], params.get("metal", 0.0))
    return mat


def bake_object(obj, mat, size):
    nt = mat.node_tree
    name = f"{obj.name}_worn"
    old = bpy.data.images.get(name)
    if old is not None:
        bpy.data.images.remove(old)
    image = bpy.data.images.new(name, size, size, alpha=False)
    image.colorspace_settings.name = "sRGB"
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = image
    for node in nt.nodes:
        node.select = False
    tex.select = True
    nt.nodes.active = tex
    bpy.ops.object.select_all(action="DESELECT")
    obj.hide_set(False)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    mesh = obj.data
    mesh.uv_layers["UVMap"].active = True
    mesh.uv_layers["UVMap"].active_render = True
    bpy.ops.object.bake(type="DIFFUSE")
    node = bsdf(mat)
    base = node.inputs["Base Color"]
    for link in list(base.links):
        nt.links.remove(link)
    nt.links.new(tex.outputs["Color"], base)
    if "Tile" in mesh.uv_layers:
        mesh.uv_layers.remove(mesh.uv_layers["Tile"])
    mesh.uv_layers["UVMap"].active = True
    mesh.uv_layers["UVMap"].active_render = True
    # Sample a few texels so a black bake fails loudly.
    pixels = image.pixels[:]
    peak = max(pixels[i] for i in range(0, min(len(pixels), 4000), 4))
    # Peak of the first thousand pixels can miss the island. Scan a stride.
    stride = max(1, (len(pixels) // 4) // 8000) * 4
    peak = 0.0
    total = 0.0
    count = 0
    for i in range(0, len(pixels), stride):
        peak = max(peak, pixels[i], pixels[i + 1], pixels[i + 2])
        total += pixels[i] + pixels[i + 1] + pixels[i + 2]
        count += 3
    mean = total / max(count, 1)
    print(f"BAKED {obj.name} {size} peak {peak:.3f} mean {mean:.3f}", flush=True)
    if peak < 0.05:
        raise RuntimeError(f"{obj.name} bake is black")
    image.filepath_raw = f"/tmp/{obj.name}_albedo.png"
    image.file_format = "PNG"
    image.save()
    image.pack()
    return image


def render_look(path):
    scene = bpy.context.scene
    cam_data = bpy.data.cameras.new("WeatherCam")
    cam_data.lens = 28
    cam = bpy.data.objects.new("WeatherCam", cam_data)
    scene.collection.objects.link(cam)
    cam.location = (1.4, -0.2, 1.55)
    # Look toward the bar (local -Y) and a bit of floor.
    direction = math.atan2(-3.2 - cam.location.y, 0.0 - cam.location.x)
    cam.rotation_euler = (math.radians(78), 0.0, direction + math.pi / 2)
    # Point -Z of the camera at the bar using a track.
    target = bpy.data.objects.new("WeatherTarget", None)
    scene.collection.objects.link(target)
    target.location = (0.2, -3.3, 0.4)
    constraint = cam.constraints.new("TRACK_TO")
    constraint.target = target
    constraint.track_axis = "TRACK_NEGATIVE_Z"
    constraint.up_axis = "UP_Y"
    scene.camera = cam
    scene.render.resolution_x = 960
    scene.render.resolution_y = 540
    scene.render.resolution_percentage = 100
    scene.cycles.samples = 12
    scene.render.filepath = path
    scene.render.image_settings.file_format = "PNG"
    bpy.ops.render.render(write_still=True)
    print("RENDERED", path, flush=True)


def jobs():
    wood = dict(
        su=0.40,
        sv=0.85,
        age=(0.9, 0.82, 0.7),
        dirt=(0.02, 0.015, 0.012),
        rough=0.96,
        metal=0.0,
        bright=0.0,
        contrast=0.28,
        sat=0.46,
        value=0.9,
    )
    dark_wood = dict(
        su=0.55,
        sv=0.7,
        age=(0.55, 0.42, 0.3),
        dirt=(0.04, 0.03, 0.02),
        rough=0.92,
        metal=0.0,
        profile="base",
        sat=0.32,
        value=0.55,
        contrast=0.2,
    )
    paper = dict(su=0.42, sv=0.56, age=(0.7, 0.6, 0.48), dirt=(0.05, 0.035, 0.025), rough=0.98, metal=0.0, profile="wall")
    return [
        ("Floor", "wood", 4096, {**wood, "profile": "floor"}),
        ("Bar", "wood", 1024, {**wood, "profile": "base"}),
        ("BarFront", "wood", 1024, {**wood, "profile": "base"}),
        ("BarTop", "wood", 1024, {**wood, "profile": "counter", "rough": 0.88}),
        ("Beam_0", "wood", 512, {**wood, "profile": "general"}),
        ("Beam_1", "wood", 512, {**wood, "profile": "general"}),
        ("Beam_2", "wood", 512, {**wood, "profile": "general"}),
        ("Roof", "thatch", 1024, dict(rough=0.97, metal=0.0, profile="general", dirt=(0.08, 0.06, 0.04))),
        ("WallLeft", "paper", 2048, paper),
        ("WallRight", "paper", 2048, paper),
        ("WallBack", "paper", 2048, paper),
        ("HallDoor", "wood", 1024, {**dark_wood, "profile": "base"}),
        ("DoorFrame", "wood", 512, {**dark_wood, "profile": "base"}),
        ("RegisterDrawer", "wood", 512, {**dark_wood, "profile": "general"}),
        ("WindowBoard_0", "wood", 512, {**wood, "profile": "general"}),
        ("WindowBoard_1", "wood", 512, {**wood, "profile": "general"}),
        ("WindowBoard_2", "wood", 512, {**wood, "profile": "general"}),
        ("Notebook", "book", 256, dict(rough=0.86, metal=0.0, profile="general", dirt=(0.08, 0.06, 0.04))),
        ("Register", "iron", 512, dict(rough=0.78, metal=0.28, profile="general", dirt=(0.1, 0.06, 0.03))),
        ("Chain", "iron", 256, dict(rough=0.84, metal=0.22, profile="general", dirt=(0.12, 0.05, 0.02))),
        ("LanternCage", "iron", 256, dict(rough=0.8, metal=0.25, profile="general", dirt=(0.1, 0.06, 0.03))),
        ("FootRail", "brass", 512, dict(rough=0.62, metal=0.45, profile="general", dirt=(0.1, 0.06, 0.03), cyl=True)),
        ("Padlock", "brass", 256, dict(rough=0.58, metal=0.48, profile="general", dirt=(0.1, 0.05, 0.02))),
        ("LanternFuse", "brass", 256, dict(rough=0.55, metal=0.5, profile="general", dirt=(0.09, 0.05, 0.02), cyl=True)),
    ]


def post_jobs():
    out = []
    for name in bpy.data.objects:
        if name.name.startswith("Post_"):
            out.append(
                (
                    name.name,
                    "wood",
                    512,
                    dict(
                        su=1.2,
                        sv=0.55,
                        age=(0.5, 0.36, 0.24),
                        dirt=(0.07, 0.05, 0.03),
                        rough=0.9,
                        metal=0.0,
                        profile="base",
                        cyl=True,
                    ),
                )
            )
    for i in range(4):
        out.append(
            (
                f"StoolSeat_{i}",
                "fabric",
                512,
                dict(rough=0.94, metal=0.0, profile="counter", dirt=(0.1, 0.08, 0.06)),
            )
        )
        for part in ("StoolPlate", "StoolShaft", "StoolRim"):
            out.append(
                (
                    f"{part}_{i}",
                    "iron",
                    256,
                    dict(rough=0.74, metal=0.32, profile="general", dirt=(0.1, 0.06, 0.03)),
                )
            )
    return out


def main():
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 1
    scene.render.bake.use_pass_direct = False
    scene.render.bake.use_pass_indirect = False
    scene.render.bake.use_pass_color = True
    scene.render.bake.margin = 16
    # Probe the mix sockets once so a Blender upgrade fails here, not after a bake.
    probe = fresh("_MixProbe", 0.5)
    mix = probe.node_tree.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    print("MIX", [(i, s.name, s.type) for i, s in enumerate(mix.inputs)], flush=True)
    bpy.data.materials.remove(probe)

    planned = jobs() + post_jobs()
    if ONLY:
        planned = [job for job in planned if job[0] == ONLY or job[0].startswith(ONLY)]
        if not planned:
            raise SystemExit(f"no job {ONLY}")
    for name, kind, size, params in planned:
        obj = bpy.data.objects[name]
        print("START", name, kind, size, flush=True)
        pack_bake_uv(obj)
        mat = build_surface(obj, kind, params)
        bake_object(obj, mat, size)

    if ONLY:
        if ONLY == "Floor":
            # Straight down, inside the room, so the boards are the whole frame.
            scene.camera = None
            cam_data = bpy.data.cameras.new("FloorCam")
            cam_data.type = "ORTHO"
            cam_data.ortho_scale = 8.0
            cam = bpy.data.objects.new("FloorCam", cam_data)
            scene.collection.objects.link(cam)
            cam.location = (0.4, -1.2, 2.3)
            cam.rotation_euler = (0.0, 0.0, 0.0)
            scene.camera = cam
            # The game lamp is dim. The blend lamp is bright enough to hide dirt.
            for light_name, energy in (("WarmLamp", 35.0), ("FlickerLantern", 18.0), ("Fill", 8.0)):
                light = bpy.data.objects.get(light_name)
                if light is not None and light.data:
                    light.data.energy = energy
            roof = bpy.data.objects.get("Roof")
            if roof is not None:
                roof.hide_render = True
            scene.cycles.samples = 16
            scene.render.resolution_x = 768
            scene.render.resolution_y = 768
            scene.render.filepath = "/tmp/lounge_weather_floor.png"
            scene.render.image_settings.file_format = "PNG"
            bpy.ops.render.render(write_still=True)
            if roof is not None:
                roof.hide_render = False
            print("PREVIEW_ONLY Floor", flush=True)
            return
        render_look(f"/tmp/lounge_weather_{ONLY}.png")
        print("PREVIEW_ONLY", ONLY, flush=True)
        return

    render_look("/tmp/lounge_weather_look.png")
    # Drop the preview camera before the game export.
    look = bpy.data.objects.get("LookCam")
    if look is not None:
        scene.camera = look
    for temp_name in ("WeatherCam", "WeatherTarget"):
        temp = bpy.data.objects.get(temp_name)
        if temp is not None:
            bpy.data.objects.remove(temp, do_unlink=True)
    for image in list(bpy.data.images):
        if image.users == 0:
            bpy.data.images.remove(image)
    for mat in list(bpy.data.materials):
        if mat.users == 0:
            bpy.data.materials.remove(mat)
    bpy.ops.wm.save_mainfile(filepath=BLEND)
    bpy.ops.export_scene.gltf(filepath=GLB, export_format="GLB", export_apply=True)
    print("SAVED", BLEND, GLB, flush=True)


if __name__ == "__main__":
    main()
