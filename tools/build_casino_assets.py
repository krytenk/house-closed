"""
Build real 3D Palm Atoll casino assets in Blender 5.x.
Exports GLBs: tiki_cabinet, casino_lounge, lobby_room.
No concept-art wallpaper — geometry + PBR only.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector

OUT = Path("/home/chriswinters/palm-atoll/art/models")
OUT.mkdir(parents=True, exist_ok=True)


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for b in list(block):
            if b.users == 0:
                block.remove(b)


def mat(name: str, color: tuple[float, float, float], rough: float = 0.45, spec: float = 0.35) -> bpy.types.Material:
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    if "Specular IOR Level" in bsdf.inputs:
        bsdf.inputs["Specular IOR Level"].default_value = spec
    return m


def assign(obj: bpy.types.Object, material: bpy.types.Material) -> None:
    if obj.data.materials:
        obj.data.materials[0] = material
    else:
        obj.data.materials.append(material)


def smooth_bevel(obj: bpy.types.Object, width: float = 0.02, segments: int = 3) -> None:
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_smooth()
    mod = obj.modifiers.new("Bevel", "BEVEL")
    mod.width = width
    mod.segments = segments
    mod.limit_method = "ANGLE"


def cube(name: str, size: tuple[float, float, float], loc: tuple[float, float, float], material: bpy.types.Material) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(scale=True)
    assign(obj, material)
    smooth_bevel(obj)
    return obj


def cylinder(name: str, radius: float, depth: float, loc: tuple[float, float, float], material: bpy.types.Material, verts: int = 32) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    assign(obj, material)
    smooth_bevel(obj, 0.01, 2)
    return obj


def sphere(name: str, radius: float, loc: tuple[float, float, float], material: bpy.types.Material) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=radius, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    assign(obj, material)
    bpy.ops.object.shade_smooth()
    return obj


def empty(name: str, loc: tuple[float, float, float]) -> bpy.types.Object:
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=loc)
    obj = bpy.context.active_object
    obj.name = name
    return obj


def export_glb(path: Path) -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(
        filepath=str(path),
        export_format="GLB",
        export_apply=True,
        export_materials="EXPORT",
        export_cameras=False,
        export_lights=True,
        check_existing=False,
    )
    print("EXPORTED", path, "bytes", path.stat().st_size)


def build_tiki_cabinet() -> None:
    clear_scene()
    wood = mat("TikiWood", (0.28, 0.14, 0.07), rough=0.42, spec=0.4)
    wood_dark = mat("TikiWoodDark", (0.14, 0.07, 0.03), rough=0.5, spec=0.3)
    amber = mat("AmberEye", (0.95, 0.55, 0.15), rough=0.25, spec=0.6)
    cream = mat("Cream", (0.92, 0.86, 0.72), rough=0.55)
    metal = mat("DarkMetal", (0.08, 0.08, 0.08), rough=0.35, spec=0.7)
    glass = mat("ReelGlass", (0.05, 0.05, 0.06), rough=0.05, spec=0.9)

    root = empty("TikiCabinet", (0, 0, 0))

    # Body — thick 3D cabinet
    body = cube("Body", (0.95, 0.72, 1.55), (0, 0, 0.95), wood)
    body.parent = root
    # Side panels for depth
    cube("SideL", (0.08, 0.78, 1.55), (-0.52, 0, 0.95), wood_dark).parent = root
    cube("SideR", (0.08, 0.78, 1.55), (0.52, 0, 0.95), wood_dark).parent = root
    # Base / legs
    cube("Base", (1.1, 0.85, 0.18), (0, 0, 0.09), wood_dark).parent = root
    for x in (-0.38, 0.38):
        for y in (-0.28, 0.28):
            cylinder("Leg", 0.06, 0.22, (x, y, 0.11), wood_dark, 12).parent = root
    # Front frame around reel window
    cube("FrameTop", (0.82, 0.06, 0.12), (0, 0.38, 1.35), wood).parent = root
    cube("FrameBot", (0.82, 0.06, 0.12), (0, 0.38, 0.72), wood).parent = root
    cube("FrameL", (0.08, 0.06, 0.55), (-0.38, 0.38, 1.03), wood).parent = root
    cube("FrameR", (0.08, 0.06, 0.55), (0.38, 0.38, 1.03), wood).parent = root
    # Glass plane (Godot will put reels behind / as children of ReelWindow)
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 0.40, 1.03))
    glass_obj = bpy.context.active_object
    glass_obj.name = "ReelGlass"
    glass_obj.scale = (0.72, 0.48, 1)
    glass_obj.rotation_euler = (math.radians(90), 0, 0)
    bpy.ops.object.transform_apply(scale=True, rotation=True)
    assign(glass_obj, glass)
    glass_obj.parent = root
    # Empty anchor at window center for Godot
    rw = empty("ReelWindow", (0, 0.42, 1.03))
    rw.parent = root

    # Tiki head
    head = cylinder("Head", 0.42, 0.55, (0, 0.05, 1.95), wood, 24)
    head.parent = root
    brow = cube("Brow", (0.7, 0.18, 0.1), (0, 0.28, 2.12), wood_dark)
    brow.parent = root
    sphere("EyeL", 0.08, (-0.14, 0.38, 2.0), amber).parent = root
    sphere("EyeR", 0.08, (0.14, 0.38, 2.0), amber).parent = root
    cube("Mouth", (0.35, 0.12, 0.08), (0, 0.38, 1.82), wood_dark).parent = root
    # Crest
    cube("Crest", (0.15, 0.2, 0.35), (0, 0.05, 2.35), cream).parent = root
    # Belly carving plate
    cube("BellyPlate", (0.7, 0.05, 0.45), (0, 0.39, 0.45), wood_dark).parent = root
    # Button ledge
    cube("ButtonLedge", (0.55, 0.2, 0.08), (0, 0.45, 0.55), metal).parent = root

    # Warm key light for export preview
    bpy.ops.object.light_add(type="AREA", location=(1.5, 2.2, 2.2))
    light = bpy.context.active_object
    light.data.energy = 80
    light.data.color = (1.0, 0.82, 0.55)
    light.data.size = 2.0

    export_glb(OUT / "tiki_cabinet.glb")


def build_casino_lounge() -> None:
    clear_scene()
    floor_m = mat("CasinoFloor", (0.18, 0.1, 0.05), rough=0.55)
    wall_m = mat("CasinoWall", (0.22, 0.12, 0.07), rough=0.65)
    thatch_m = mat("Thatch", (0.55, 0.38, 0.18), rough=0.85)
    plaster = mat("DarkPlaster", (0.12, 0.1, 0.09), rough=0.7)
    ocean = mat("NightOcean", (0.02, 0.08, 0.14), rough=0.15, spec=0.7)
    bar_wood = mat("BarWood", (0.32, 0.16, 0.07), rough=0.4)
    cushion = mat("Cushion", (0.75, 0.55, 0.35), rough=0.6)

    root = empty("CasinoLounge", (0, 0, 0))

    floor = cube("Floor", (7.0, 5.0, 0.12), (0, 0, 0), floor_m)
    floor.parent = root
    # Walls
    back = cube("WallBack", (7.0, 0.2, 2.4), (0, -4.8, 1.25), wall_m)
    back.parent = root
    left = cube("WallLeft", (0.2, 5.0, 2.4), (-6.9, 0, 1.25), wall_m)
    left.parent = root
    right = cube("WallRight", (0.2, 5.0, 2.4), (6.9, 0, 1.25), wall_m)
    right.parent = root
    # Open ocean wall (thin dark plane + ocean beyond)
    ocean_plane = cube("Ocean", (7.2, 0.15, 2.6), (0, 5.2, 1.2), ocean)
    ocean_plane.parent = root
    # Posts
    for x in (-5.5, -1.8, 1.8, 5.5):
        for y in (-3.5, 3.5):
            p = cylinder(f"Post_{x}_{y}", 0.12, 2.6, (x, y, 1.35), bar_wood, 16)
            p.parent = root
    # Thatch roof
    roof = cube("Roof", (7.4, 5.4, 0.25), (0, 0, 2.75), thatch_m)
    roof.parent = root
    # Bar
    bar = cube("Bar", (4.5, 0.55, 0.95), (0, -3.6, 0.55), bar_wood)
    bar.parent = root
    bar_top = cube("BarTop", (4.7, 0.7, 0.08), (0, -3.6, 1.08), mat("BarTop", (0.45, 0.25, 0.1), 0.3))
    bar_top.parent = root
    # Stools
    for i, x in enumerate((-2.4, -0.8, 0.8, 2.4)):
        seat = cylinder(f"Stool_{i}", 0.22, 0.08, (x, -2.6, 0.55), cushion, 20)
        seat.parent = root
        leg = cylinder(f"StoolLeg_{i}", 0.05, 0.5, (x, -2.6, 0.28), bar_wood, 10)
        leg.parent = root
    # Cabinet spawn markers (Godot places cabinets here)
    for i, x in enumerate((-2.4, 0.0, 2.4)):
        m = empty(f"CabinetSpawn_{i}", (x, 2.2, 0))
        m.parent = root
    # Player spawn / camera hint
    empty("PlayerSpawn", (0, -1.5, 0)).parent = root
    empty("HallEntry", (0, -4.5, 0)).parent = root

    bpy.ops.object.light_add(type="AREA", location=(0, 0, 2.4))
    light = bpy.context.active_object
    light.data.energy = 120
    light.data.color = (1.0, 0.7, 0.4)
    light.data.size = 4.0
    light.parent = root

    # Moon fill
    bpy.ops.object.light_add(type="AREA", location=(0, 6, 2.5))
    moon = bpy.context.active_object
    moon.data.energy = 40
    moon.data.color = (0.4, 0.5, 0.75)
    moon.data.size = 3.0

    export_glb(OUT / "casino_lounge.glb")


def build_lobby_room() -> None:
    clear_scene()
    plaster = mat("CreamPlaster", (0.93, 0.88, 0.78), rough=0.75)
    wood = mat("LobbyWood", (0.45, 0.28, 0.12), rough=0.45)
    wood_dark = mat("LobbyWoodDark", (0.25, 0.14, 0.06), rough=0.5)
    linen = mat("Linen", (0.85, 0.78, 0.65), rough=0.7)
    stone = mat("Stone", (0.55, 0.5, 0.42), rough=0.8)
    glass = mat("Window", (0.55, 0.75, 0.85), rough=0.05, spec=0.9)

    root = empty("LobbyRoom", (0, 0, 0))

    floor = cube("Floor", (6.0, 5.0, 0.12), (0, 0, 0), wood)
    floor.parent = root
    # Walls
    cube("WallBack", (6.0, 0.2, 2.8), (0, -4.9, 1.45), plaster).parent = root
    cube("WallLeft", (0.2, 5.0, 2.8), (-5.9, 0, 1.45), plaster).parent = root
    # Right wall with hall opening (gap)
    cube("WallRightA", (0.2, 1.6, 2.8), (5.9, -3.2, 1.45), plaster).parent = root
    cube("WallRightB", (0.2, 1.6, 2.8), (5.9, 3.2, 1.45), plaster).parent = root
    cube("WallRightTop", (0.2, 1.8, 0.6), (5.9, 0, 2.55), plaster).parent = root
    # Front open toward garden / soft glass
    cube("FrontGlass", (5.5, 0.08, 2.2), (0, 4.9, 1.3), glass).parent = root
    # Ceiling
    cube("Ceiling", (6.2, 5.2, 0.15), (0, 0, 2.9), plaster).parent = root
    # Desk
    cube("Desk", (2.2, 0.7, 0.95), (-2.2, -2.8, 0.55), wood_dark).parent = root
    cube("DeskTop", (2.35, 0.85, 0.08), (-2.2, -2.8, 1.08), wood).parent = root
    # Sofa
    cube("Sofa", (2.0, 0.75, 0.55), (2.0, -2.5, 0.4), linen).parent = root
    cube("SofaBack", (2.0, 0.25, 0.7), (2.0, -2.95, 0.7), linen).parent = root
    # Rug
    cube("Rug", (2.4, 1.8, 0.03), (0.3, 0.2, 0.08), mat("Rug", (0.55, 0.22, 0.18), 0.85)).parent = root
    # Planter
    cylinder("Planter", 0.28, 0.45, (-4.5, 3.5, 0.3), stone, 16).parent = root
    # Hall marker (Godot Area)
    empty("HallPortal", (5.5, 0.0, 0)).parent = root
    empty("PlayerSpawn", (0, 2.5, 0)).parent = root

    bpy.ops.object.light_add(type="AREA", location=(0, 0, 2.6))
    light = bpy.context.active_object
    light.data.energy = 100
    light.data.color = (1.0, 0.9, 0.75)
    light.data.size = 3.5

    # Warm window light from hall
    bpy.ops.object.light_add(type="AREA", location=(6.5, 0, 1.6))
    hall_light = bpy.context.active_object
    hall_light.data.energy = 60
    hall_light.data.color = (1.0, 0.75, 0.4)
    hall_light.data.size = 1.5
    hall_light.rotation_euler = (0, math.radians(-90), 0)

    export_glb(OUT / "lobby_room.glb")


def main() -> None:
    target = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "all"
    if target in ("cabinet", "all"):
        build_tiki_cabinet()
    if target in ("casino", "all"):
        build_casino_lounge()
    if target in ("lobby", "all"):
        build_lobby_room()
    print("DONE", target)


if __name__ == "__main__":
    main()
