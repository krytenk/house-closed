"""Abandoned Paloma lounge — Blender scene for House Closed Room 01.

Godot loads the exported GLB and only scripts named sockets:
  PaperFlap, BirdPivot, CabinetSpawn_0/1/2, Notebook, Register,
  HallDoor, LanternFuse, PlayerSpawn
"""
from __future__ import annotations

import math
from pathlib import Path

import bpy
from mathutils import Vector, Euler

ART = Path("/home/chriswinters/palm-atoll/art/seasons/paloma")
OUT = Path("/home/chriswinters/palm-atoll/art/models/abandoned_lounge.glb")
WOOD = ART / "wood.png"
PLANK = ART / "tiles_ref" / "wood_plank.png"
THATCH = ART / "tiles_ref" / "thatch.png"


def bsdf(mat: bpy.types.Material):
    return next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")


def mat_color(name: str, color, rough=0.5, metal=0.0, emit=0.0) -> bpy.types.Material:
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = bsdf(m)
    b.inputs["Base Color"].default_value = (*color, 1.0)
    b.inputs["Roughness"].default_value = rough
    if "Metallic" in b.inputs:
        b.inputs["Metallic"].default_value = metal
    if emit > 0 and "Emission Strength" in b.inputs:
        b.inputs["Emission Color"].default_value = (*color, 1.0)
        b.inputs["Emission Strength"].default_value = emit
    return m


def mat_tex(name: str, path: Path, rough=0.55, scale=2.0, metal=0.0) -> bpy.types.Material:
    m = mat_color(name, (0.4, 0.3, 0.2), rough, metal)
    if not path.exists():
        return m
    nt = m.node_tree
    b = bsdf(m)
    img = bpy.data.images.load(str(path), check_existing=True)
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.location = (-400, 0)
    mapn = nt.nodes.new("ShaderNodeMapping")
    mapn.inputs["Scale"].default_value = (scale, scale, scale)
    mapn.location = (-620, 0)
    coord = nt.nodes.new("ShaderNodeTexCoord")
    coord.location = (-840, 0)
    nt.links.new(coord.outputs["UV"], mapn.inputs["Vector"])
    nt.links.new(mapn.outputs["Vector"], tex.inputs["Vector"])
    nt.links.new(tex.outputs["Color"], b.inputs["Base Color"])
    return m


def assign(obj, material):
    if obj.data.materials:
        obj.data.materials[0] = material
    else:
        obj.data.materials.append(material)


def uv_smart(obj):
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    try:
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.02)
        bpy.ops.object.mode_set(mode="OBJECT")
    except Exception:
        if bpy.context.mode != "OBJECT":
            bpy.ops.object.mode_set(mode="OBJECT")
    obj.select_set(False)


def cube(name, size, loc, material, parent=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    assign(obj, material)
    uv_smart(obj)
    if parent:
        obj.parent = parent
    return obj


def cyl(name, r, h, loc, material, parent=None, verts=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=r, depth=h, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    assign(obj, material)
    uv_smart(obj)
    if parent:
        obj.parent = parent
    return obj


def plane(name, w, h, loc, rot, material, parent=None):
    bpy.ops.mesh.primitive_plane_add(size=1, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (w / 2.0, h / 2.0, 1.0)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    assign(obj, material)
    uv_smart(obj)
    if parent:
        obj.parent = parent
    return obj


def empty(name, loc, parent=None):
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.empty_display_size = 0.25
    if parent:
        obj.parent = parent
    return obj


def stool(i, x, y, metal, fabric, parent):
    root = empty(f"Stool_{i}", (x, y, 0), parent)
    # floor plate
    plate = cyl(f"StoolPlate_{i}", 0.16, 0.025, (x, y, 0.013), metal, parent, 20)
    plate.parent = root
    plate.location = (0, 0, 0.013)
    shaft = cyl(f"StoolShaft_{i}", 0.028, 0.46, (x, y, 0.26), metal, parent, 12)
    shaft.parent = root
    shaft.location = (0, 0, 0.26)
    seat = cyl(f"StoolSeat_{i}", 0.21, 0.055, (x, y, 0.51), fabric, parent, 24)
    seat.parent = root
    seat.location = (0, 0, 0.51)
    rim = cyl(f"StoolRim_{i}", 0.215, 0.02, (x, y, 0.48), metal, parent, 24)
    rim.parent = root
    rim.location = (0, 0, 0.48)
    return root


def build():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for coll in (bpy.data.meshes, bpy.data.materials, bpy.data.images, bpy.data.cameras, bpy.data.lights):
        for b in list(coll):
            if b.users == 0:
                coll.remove(b)
    wood = mat_tex("BarWood", WOOD, rough=0.42, scale=1.6)
    plank = mat_tex("FloorPlank", PLANK, rough=0.6, scale=3.5)
    thatch = mat_tex("ThatchRoof", THATCH, rough=0.85, scale=2.2)
    plaster = mat_color("DirtyPlaster", (0.42, 0.34, 0.26), 0.86)
    paper = mat_color("Wallpaper", (0.55, 0.42, 0.30), 0.82)
    paper_old = mat_color("WallpaperFaded", (0.62, 0.50, 0.36), 0.8)
    metal = mat_color("AgedMetal", (0.28, 0.26, 0.24), 0.35, metal=0.85)
    brass = mat_color("Brass", (0.62, 0.45, 0.18), 0.32, metal=0.7)
    fabric = mat_color("SeatFabric", (0.28, 0.12, 0.10), 0.78)
    board = mat_tex("BoardWood", WOOD, rough=0.7, scale=0.8)
    dark = mat_color("DoorWood", (0.14, 0.08, 0.05), 0.7)
    night = mat_color("NightGlass", (0.04, 0.06, 0.09), 0.2)
    fruit_g = mat_color("FruitGold", (0.85, 0.58, 0.12), 0.4)
    fruit_l = mat_color("FruitLeaf", (0.22, 0.42, 0.14), 0.5)
    fruit_c = mat_color("FruitCoco", (0.45, 0.28, 0.12), 0.55)

    root = empty("LoungeRoot", (0, 0, 0))

    # Floor 14 x 10 (matches prior room)
    floor = cube("Floor", (14.0, 10.0, 0.12), (0, 0, -0.06), plank, root)
    # Walls
    cube("WallBack", (14.1, 0.18, 2.7), (0, -4.95, 1.35), plaster, root)
    cube("WallLeft", (0.18, 10.0, 2.7), (-6.95, 0, 1.35), plaster, root)
    cube("WallRight", (0.18, 10.0, 2.7), (6.95, 0, 1.35), plaster, root)
    # Wallpaper sheets on left wall (the room look — not a puzzle box)
    wp = plane("WallpaperLeft", 4.6, 2.2, (-6.82, 0.4, 1.35), (math.pi / 2, 0, math.pi / 2), paper, root)
    # PaperFlap kept as a named socket; Godot hides it. Clue is the house-line plaque.
    bpy.ops.mesh.primitive_plane_add(size=1, location=(0, 0, 0))
    flap = bpy.context.active_object
    flap.name = "PaperFlap"
    flap.scale = (0.45, 0.32, 1.0)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    # Move geometry down so origin stays at the top edge
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.transform.translate(value=(0, -0.32, 0))
    bpy.ops.object.mode_set(mode="OBJECT")
    assign(flap, paper_old)
    uv_smart(flap)
    flap.location = (-6.76, 1.55, 1.58)
    flap.rotation_euler = (math.pi / 2, 0.18, math.pi / 2)
    flap.parent = root

    # Ocean / boarded window on +Y
    cube("Ocean", (3.4, 0.08, 1.1), (0, 4.92, 1.4), night, root)
    for i, x in enumerate((-1.1, 0.0, 1.1)):
        b = cube(f"WindowBoard_{i}", (1.5, 0.05, 0.12), (x, 4.78, 1.15 + i * 0.28), board, root)
        b.rotation_euler.z = math.radians(-6 + i * 6)

    # Posts + roof beams
    for x in (-5.2, -1.7, 1.7, 5.2):
        for y in (-3.6, 3.6):
            cyl(f"Post_{x}_{y}", 0.11, 2.7, (x, y, 1.35), wood, root, 12)
    cube("Roof", (14.4, 10.4, 0.16), (0, 0, 2.78), thatch, root)
    for i, y in enumerate((-2.4, 0.0, 2.4)):
        cube(f"Beam_{i}", (6.8, 0.12, 0.16), (0, y, 2.62), wood, root)

    # Bar
    cube("BarFront", (2.3, 0.08, 0.48), (0, -3.55, 0.48), wood, root)
    cube("Bar", (2.3, 0.28, 0.48), (0, -3.78, 0.48), wood, root)
    cube("BarTop", (2.4, 0.38, 0.05), (0, -3.7, 1.00), wood, root)
    rail = cyl("FootRail", 0.03, 4.2, (0, -3.42, 0.22), brass, root, 12)
    rail.rotation_euler.y = math.pi / 2

    # Stools
    for i, x in enumerate((-1.6, -0.55, 0.55, 1.6)):
        stool(i, x, -2.85, metal, fabric, root)

    # Door in the back wall
    cube("DoorFrame", (0.85, 0.08, 1.15), (0, -4.78, 1.15), dark, root)
    door = cube("HallDoor", (0.72, 0.05, 1.05), (0, -4.68, 1.1), dark, root)
    cube("Padlock", (0.06, 0.05, 0.08), (0.28, -4.60, 1.15), brass, root)
    chain = cyl("Chain", 0.02, 0.7, (0.05, -4.58, 1.18), metal, root, 8)
    chain.rotation_euler.y = math.radians(80)

    # Register sitting on the bar — modeled, not a Godot box
    cube("Register", (0.22, 0.16, 0.12), (0.85, -3.55, 1.12), metal, root)
    cube("RegisterScreen", (0.16, 0.02, 0.09), (0.85, -3.46, 1.22), mat_color("CRT", (0.05, 0.08, 0.05), 0.3), root)
    cube("RegisterDrawer", (0.2, 0.14, 0.04), (0.85, -3.55, 1.04), dark, root)

    # Notebook on the floor by a stool
    cube("Notebook", (0.12, 0.16, 0.015), (-0.7, -2.55, 0.03), mat_color("Book", (0.22, 0.1, 0.07), 0.6), root)

    # Lantern hanging from a beam
    lantern = cyl("LanternFuse", 0.07, 0.16, (-2.2, -1.4, 2.35), brass, root, 10)
    cube("LanternCage", (0.09, 0.09, 0.12), (-2.2, -1.4, 2.22), metal, root)

    # Cabinet sockets (Godot instances machines here)
    for i, x in enumerate((-2.5, 0.0, 2.5)):
        empty(f"CabinetSpawn_{i}", (x, 2.15, 0), root)
    empty("BirdPivot", (-2.5, 2.15, 1.9), root)
    empty("PlayerSpawn", (-2.5, -1.15, 0.1), root)

    # Lights
    bpy.ops.object.light_add(type="POINT", location=(0, 0, 2.3))
    lamp = bpy.context.active_object
    lamp.name = "WarmLamp"
    lamp.data.energy = 250
    lamp.data.color = (1.0, 0.78, 0.52)
    lamp.data.shadow_soft_size = 0.4
    lamp.parent = root
    bpy.ops.object.light_add(type="POINT", location=(-2.2, -1.4, 2.2))
    flick = bpy.context.active_object
    flick.name = "FlickerLantern"
    flick.data.energy = 80
    flick.data.color = (1.0, 0.62, 0.32)
    flick.parent = root
    bpy.ops.object.light_add(type="AREA", location=(0, -2.0, 2.4))
    fill = bpy.context.active_object
    fill.name = "Fill"
    fill.data.energy = 120
    fill.data.color = (1.0, 0.85, 0.7)
    fill.data.size = 4.0
    fill.rotation_euler = Euler((math.radians(-40), 0, 0), "XYZ")
    fill.parent = root

    # Camera looking at the bar and stools
    bpy.ops.object.camera_add(location=(1.8, -0.6, 1.65))
    cam = bpy.context.active_object
    cam.name = "LookCam"
    direction = Vector((0.0, -3.5, 0.9)) - Vector(cam.location)
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    bpy.context.scene.camera = cam
    world = bpy.context.scene.world or bpy.data.worlds.new("World")
    bpy.context.scene.world = world
    world.use_nodes = True
    bg = next(n for n in world.node_tree.nodes if n.type == "BACKGROUND")
    bg.inputs[0].default_value = (0.04, 0.03, 0.02, 1)
    bg.inputs[1].default_value = 0.6
    print("lounge built", len(bpy.data.objects))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=str(OUT),
        export_format="GLB",
        export_apply=True,
        export_cameras=False,
        export_lights=True,
    )
    blend = OUT.with_suffix(".blend")
    bpy.ops.wm.save_as_mainfile(filepath=str(blend))
    print("exported", OUT, "bytes", OUT.stat().st_size if OUT.exists() else 0)
    print("saved", blend)


if __name__ == "__main__":
    build()
