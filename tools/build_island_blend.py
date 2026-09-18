"""Build Paloma Atoll in Blender from the locked concept paintings. Export GLB."""
import bpy
import bmesh
import math
from mathutils import Vector
from pathlib import Path

ROOT = Path("/home/chriswinters/palm-atoll")
TEX = ROOT / "art/seasons/paloma/tiles_ref"
OUT = ROOT / "art/seasons/paloma/models"
OUT.mkdir(parents=True, exist_ok=True)

TILE_TEX = [
    str(TEX / "hibiscus_tile.png"),
    str(TEX / "palm_tile.png"),
    str(TEX / "anchor.png"),
    str(TEX / "coconut_a.png"),
    str(TEX / "shell_a.png"),
    str(TEX / "sail_a.png"),
    str(TEX / "star_a.png"),
    str(TEX / "coconut_tile.png"),
    str(TEX / "sail_tile.png"),
]


def nuke():
    bpy.ops.object.select_all(action="SELECT")
    # keep world
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)


def smooth(obj):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_smooth()


def bevel(obj, width=0.06, segs=3):
    m = obj.modifiers.new("Bevel", "BEVEL")
    m.width = width
    m.segments = segs
    m.limit_method = "ANGLE"


def mat_tex(name, path, spec=0.15, rough=0.55):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(path, check_existing=True)
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Specular IOR Level"].default_value = spec
    return m


def mat_col(name, rgb, rough=0.55, spec=0.2):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Base Color"].default_value = (*rgb, 1)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Specular IOR Level"].default_value = spec
    return m


def reuse(name):
    return bpy.data.materials.get(name)


def add_cyl(r, d, loc, mat, verts=48, name="Cyl"):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=d, location=loc)
    o = bpy.context.active_object
    o.name = name
    if mat:
        o.data.materials.append(mat)
    smooth(o)
    return o


def add_cube(s, loc, mat, name="Cube"):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = s
    bpy.ops.object.transform_apply(scale=True)
    if mat:
        o.data.materials.append(mat)
    bevel(o)
    smooth(o)
    return o


def add_uvsphere(r, loc, mat, name="Sph"):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=r, location=loc)
    o = bpy.context.active_object
    o.name = name
    if mat:
        o.data.materials.append(mat)
    smooth(o)
    return o


def add_cone(r1, depth, loc, mat, name="Cone"):
    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=r1, radius2=0.02, depth=depth, location=loc)
    o = bpy.context.active_object
    o.name = name
    if mat:
        o.data.materials.append(mat)
    bevel(o, 0.03, 2)
    smooth(o)
    return o


def build():
    nuke()
    sand_m = reuse("coast_sand_01")
    wood_m = reuse("brown_planks_03")
    bamboo_m = reuse("bamboo_wall")
    water_m = mat_col("LagoonWater", (0.12, 0.72, 0.68), rough=0.08, spec=0.6)
    bsdf = next(n for n in water_m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Transmission Weight"].default_value = 0.55
    bsdf.inputs["IOR"].default_value = 1.33
    ocean_m = mat_col("Ocean", (0.03, 0.28, 0.32), rough=0.12, spec=0.5)
    cream = mat_col("Cream", (0.96, 0.93, 0.86), 0.45)
    thatch = mat_col("Thatch", (0.72, 0.55, 0.28), 0.8)
    coral = mat_col("Coral", (0.86, 0.42, 0.32), 0.4)
    teal = mat_col("Teal", (0.18, 0.72, 0.68), 0.4)
    pink = mat_col("Pink", (0.88, 0.38, 0.52), 0.4)
    ink = mat_col("Ink", (0.07, 0.07, 0.07), 0.35)
    gold = mat_col("Lantern", (0.95, 0.62, 0.32), 0.35)

    # Ocean
    add_cyl(48, 0.6, (0, 0, -0.55), ocean_m, 64, "Ocean")
    # Sand cay
    add_cyl(8.2, 0.5, (0, 0, -0.05), sand_m, 64, "Sand")
    # Lagoon
    add_cyl(3.2, 0.18, (0.5, 0.4, 0.18), water_m, 48, "Lagoon")
    # Boardwalk ring via torus
    bpy.ops.mesh.primitive_torus_add(
        major_radius=9.5, minor_radius=1.15, major_segments=72, minor_segments=16, location=(0, 0, 0.12)
    )
    ring = bpy.context.active_object
    ring.name = "Boardwalk"
    ring.rotation_euler = (0, 0, 0)
    if wood_m:
        ring.data.materials.append(wood_m)
    smooth(ring)

    # 24 tiles
    tile_mats = []
    for i, p in enumerate(TILE_TEX):
        try:
            tile_mats.append(mat_tex(f"TileTex{i}", p, spec=0.12, rough=0.48))
        except Exception:
            tile_mats.append(cream)
    for i in range(24):
        ang = i / 24.0 * math.tau
        x, y = math.cos(ang) * 9.5, math.sin(ang) * 9.5
        t = add_cube((1.55, 1.55, 0.22), (x, y, 0.32), tile_mats[i % len(tile_mats)], f"Tile_{i:02d}")
        t.rotation_euler = (0, 0, ang)

    # Bungalows outside west arc
    for i in range(5):
        ang = math.radians(155 + i * 16)
        x, y = math.cos(ang) * 14.2, math.sin(ang) * 14.2
        bungalow(x, y, ang + math.pi, wood_m, cream, thatch, teal)

    # Palms
    for i in range(10):
        ang = math.radians(15 + i * 32)
        palm(math.cos(ang) * 5.6, math.sin(ang) * 5.6, bamboo_m or wood_m)

    # Pavilions
    pavilion(math.cos(math.radians(125)) * 13.6, math.sin(math.radians(125)) * 13.6, math.radians(125) + math.pi, wood_m, thatch, mat_col("Felt", (0.08, 0.38, 0.26), 0.5))
    pavilion(-0.2, -5.4, 0, wood_m, thatch, mat_col("DarkWood", (0.28, 0.16, 0.08), 0.5))

    # Tide machine
    tide(3.2, 1.5, wood_m, pink, teal, gold, coral)

    # Pelican
    pelican(7.4, -7.2, cream, gold, ink, wood_m)

    # Dock + boats
    dock_ang = math.radians(210)
    dx, dy = math.cos(dock_ang) * 12.2, math.sin(dock_ang) * 12.2
    add_cube((3.6, 1.2, 0.14), (dx, dy, 0.05), wood_m, "Dock")
    bpy.context.active_object.rotation_euler = (0, 0, dock_ang)
    boat(dx + math.cos(dock_ang + 0.5) * 1.8, dy + math.sin(dock_ang + 0.5) * 1.8, dock_ang, cream)
    boat(dx + math.cos(dock_ang + 0.85) * 2.4, dy + math.sin(dock_ang + 0.85) * 2.4, dock_ang, coral)

    # Sun
    bpy.ops.object.light_add(type="SUN", location=(12, -8, 18))
    sun = bpy.context.active_object
    sun.data.energy = 4.5
    sun.data.color = (1.0, 0.86, 0.62)
    sun.rotation_euler = (math.radians(48), math.radians(20), math.radians(40))

    # Camera ~35°
    bpy.ops.object.camera_add(location=(18, -20, 16))
    cam = bpy.context.active_object
    cam.name = "HeroCam"
    cam.data.lens = 35
    # aim at origin
    direction = Vector((0, 0, 0.4)) - cam.location
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = cam

    # EEVEE look
    bpy.context.scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in dir(bpy.types.RenderSettings) or True else "BLENDER_EEVEE"
    try:
        bpy.context.scene.render.engine = "BLENDER_EEVEE"
    except Exception:
        pass
    bpy.context.scene.render.resolution_x = 1920
    bpy.context.scene.render.resolution_y = 1080
    bpy.context.scene.render.filepath = str(OUT / "blender_hero.png")


def bungalow(x, y, yaw, wood, cream, thatch, teal):
    for sx, sy in ((-0.7, -0.7), (0.7, -0.7), (-0.7, 0.7), (0.7, 0.7)):
        add_cyl(0.08, 1.7, (x + sx, y + sy, 0.45), wood, 8, "Stilt")
    deck = add_cube((2.3, 2.3, 0.12), (x, y, 1.25), wood, "Deck")
    house = add_cube((1.75, 1.75, 1.15), (x, y, 1.9), cream, "House")
    roof = add_cone(1.45, 0.9, (x, y, 2.7), thatch, "Roof")
    win = add_cube((0.4, 0.08, 0.45), (x, y + 0.9, 1.85), teal, "Win")
    for o in (deck, house, roof, win):
        o.rotation_euler[2] = yaw


def palm(x, y, bark):
    green = mat_col("Frond", (0.18, 0.55, 0.22), 0.65)
    add_cyl(0.11, 2.6, (x + 0.05, y, 1.3), bark, 8, "Trunk")
    bpy.context.active_object.rotation_euler = (math.radians(6), 0, 0)
    for i in range(7):
        a = i / 7 * math.tau
        add_uvsphere(0.42, (x + math.cos(a) * 0.5, y + math.sin(a) * 0.5, 2.7), green, "Frond")
    add_uvsphere(0.28, (x, y, 2.75), green, "Crown")


def pavilion(x, y, yaw, wood, thatch, floor):
    for sx, sy in ((-1.4, -1.4), (1.4, -1.4), (-1.4, 1.4), (1.4, 1.4)):
        add_cyl(0.1, 2.3, (x + sx, y + sy, 0.7), wood, 8, "Post")
    add_cube((3.3, 3.3, 0.12), (x, y, 1.9), wood, "PavDeck")
    add_cone(2.15, 1.05, (x, y, 2.55), thatch, "PavRoof")
    add_cube((1.9, 1.9, 0.08), (x, y, 1.22), floor, "PavFloor")


def tide(x, y, wood, pink, teal, gold, coral):
    add_cube((2.6, 2.6, 0.22), (x, y, 0.15), teal, "SplashDeck")
    add_cyl(0.12, 4.8, (x - 0.9, y + 0.2, 2.5), wood, 8, "TowerL")
    add_cyl(0.12, 4.8, (x + 0.9, y + 0.2, 2.5), wood, 8, "TowerR")
    bpy.ops.mesh.primitive_torus_add(major_radius=0.7, minor_radius=0.08, location=(x, y, 4.6))
    w = bpy.context.active_object
    w.name = "ShipWheel"
    w.data.materials.append(pink)
    w.rotation_euler = (math.radians(90), 0, math.radians(15))
    add_cyl(0.5, 0.16, (x + 0.2, y + 0.35, 3.7), gold, 16, "Gear")
    bpy.context.active_object.rotation_euler = (math.radians(90), 0, 0)
    add_cyl(0.14, 1.5, (x + 1.0, y - 0.2, 4.0), mat_col("Pipe", (0.42, 0.35, 0.62), 0.4), 10, "Pipe")
    bpy.context.active_object.rotation_euler = (0, 0, math.radians(50))
    add_cyl(0.3, 0.4, (x + 1.15, y - 0.5, 2.6), teal, 12, "Bucket")
    add_cube((0.75, 0.38, 0.08), (x + 1.3, y - 0.9, 2.2), pink, "FlipFlop")
    add_uvsphere(0.24, (x - 0.5, y - 0.2, 2.3), mat_col("Coco", (0.32, 0.18, 0.08), 0.55), "Coconut")
    add_uvsphere(0.22, (x - 1.15, y + 0.4, 1.55), coral, "Crab")
    add_cube((1.35, 0.42, 0.1), (x + 0.4, y - 0.85, 1.55), gold, "Board")
    add_cyl(0.58, 0.7, (x + 0.2, y - 1.15, 0.7), wood, 12, "Cage")


def pelican(x, y, cream, gold, ink, wood):
    add_cyl(0.18, 1.2, (x, y, 0.45), wood, 10, "Piling")
    add_uvsphere(0.34, (x, y, 1.2), cream, "Body")
    add_uvsphere(0.22, (x + 0.12, y + 0.12, 1.48), cream, "Head")
    add_cube((0.55, 0.12, 0.1), (x + 0.42, y + 0.22, 1.42), gold, "Beak")
    add_cyl(0.09, 0.04, (x + 0.22, y + 0.28, 1.52), ink, 12, "LensL")
    add_cyl(0.09, 0.04, (x + 0.08, y + 0.32, 1.54), ink, 12, "LensR")


def boat(x, y, yaw, hull):
    h = add_cube((1.9, 0.72, 0.38), (x, y, 0.22), hull, "Hull")
    add_cube((0.7, 0.55, 0.4), (x, y, 0.52), mat_col("Cabin", (0.96, 0.93, 0.86), 0.45), "Cabin")
    h.rotation_euler[2] = yaw


def export():
    glb = str(OUT / "paloma_island.glb")
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(
        filepath=glb,
        export_format="GLB",
        export_materials="EXPORT",
        export_cameras=False,
        export_lights=True,
        check_existing=False,
    )
    print("EXPORTED", glb)
    bpy.context.scene.render.filepath = str(OUT / "blender_hero.png")
    bpy.ops.render.render(write_still=True)
    print("RENDERED", bpy.context.scene.render.filepath)


build()
export()
print("DONE")
