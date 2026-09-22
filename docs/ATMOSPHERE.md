# Atmosphere master plan

How House Closed sounds and thickens. Quiet abandonment. This file is the plan. Do not build it during a puzzle fix.

Room 01 has no audio. The hour is silent. That is the start, not a hole to fill with a score.

## Laws

- The building is the music. No theme that follows the guest. No cheer on a pay.
- No heartbeat, rising tempo, or ticking clock. Those read as hurry. This house does not hurry.
- No jump scare unless that room's `ROOM.md` asks for one. None do.
- A jackpot is a tired click in an empty room. Never `audio/win.wav`.
- Taking the fuse must make the room darker. The green till is then the bright thing.
- The end does not resolve. After the chain, the same bed continues under the sealed-lobby line.
- Red herrings for the ear are good. A sound at the boards can be only the ocean.

## Bed

One loop for the whole hour, quiet: wood, a far thud behind the boarded window, a thin hum from the lantern. It starts when the wake blinks finish and the guest can look. It does not swell.

The lantern hum is part of the bed until `fuse` is taken. Then the hum stops and stays stopped.

## The only motif

Three notes. Pineapple, leaf, coconut. Play them once, when the house line is read (`wallpaper`). Not before. Not again. Not a melody that returns at the door.

## Room 01 beats

The puzzle order does not change. Sound only marks beats that already happen.

| When | Sound | Light |
|---|---|---|
| Wake | Blink cut scene, then the bed. No scare chord. | Dark, light, dark, light, then the room as it is |
| Bird turns | Dry pin | — |
| Coins dump | Brass on the floor. Loudest innocent moment | — |
| House line | The three notes, once | — |
| Each centre symbol | Tired click. Not a slot machine | — |
| Window pays | Till click, then silence in the bed. Nobody cheers | Till stays dark |
| Fuse leaves the lantern | Hum dies | Room dims. Centre lamp and ambient drop. Flicker stays dead |
| Fuse enters the till | Screen cough, already in the line | Green screen is the bright spot |
| Chain drops | Loudest sound in the hour | — |
| Lobby line | Bed does not cadence | End card on the same tone |

Ears can lie the way the empty stool lies. The boarded window may thud. It is the building, not a visitor.

## Seen reading

Wake is the only cut. Point of view. Eyes blink: dark, light, dark, light. He is on the casino floor, confused, and looks around. Narration carries that, then control returns.

Later reads stay in first person. Camera does not cut away. He is already looking at the page, the plaque, the notice, or the slip. The line is spoken, and he sees the object. The bottom hint can remain for play. It is not a substitute for seeing the page.

Notebook, house line, window notice, and slip `418` are the reads. The stool, the jammed hopper, and a thud at the boards are not reads. They waste attention.

## What is already there

| Thing | Now |
|---|---|
| Audio players | None in `lounge_escape.gd` |
| Legacy files | `audio/click.wav`, `steel.wav`, `surf.wav`, `win.wav`. Listen before use. `win.wav` stays unused |
| Ceiling lamp | Omni at `(0, 2.4, 0.2)`, energy `2.2`, range `14`. This keeps the room bright after the fuse unless it is dimmed on purpose |
| Lantern flicker | `FlickerLantern`. Dies down once `fuse` is set. `_process` stops animating it |
| Till light | Off until `fuse_in`, then green on `RegisterScreen` |
| Fill and ambient | Directional energy `0.35`. Ambient energy `0.55`. Fog density `0.004` |
| Wake | One text line, then it fades. Not a blink yet |
| Till pad | A panel in the middle of the screen. Not on the till |

## Build order

Do not start this until the polish that the sound has to sit on is in. That polish is already noted in `rooms/room_01_lounge/traps/README.md`:

1. Wake blink cut scene (this plan's opening).
2. Till more detailed. Keypad on the front of the till. No pad from behind it.
3. Abandonment pass on the lounge and the Godot machines, so a dirty room is not still full of new cabinets. Weathering can lag the first bed. It should not lag the dimming, or the guest darkens a toy.

Then, in the room script only. No new autoload. `systems/*` stays director-owned.

1. **Bed.** One looping player, started at the end of the wake. New recording, or `surf.wav` only if a listen proves it is a far window and not a beach theme. Very quiet.
2. **One-shots on calls that already exist.** Bird pin and coin dump in the bird finish. Reel click in `_cycle_reel`. Till click in `_do_jackpot`. Chain in `_use_door`. No event bus.
3. **Three notes.** Once, inside the house-line use, when `wallpaper` flips true.
4. **Darken on the fuse.** Keep a reference to the ceiling lamp. On `fuse`, drop that lamp, the fill, and the ambient. Do not only stop the flicker. The green till stays the bright spot after `fuse_in`.
5. **Seen reads.** Narration on notebook, house line, notice, and slip, while the object is in view. Wake remains the only blink.
6. **Door.** Chain, then the same bed under the end card. No final chord.

## In Room 01 now

Started. Not a finished mix. A played listen is still the check. A screenshot cannot prove a sound.

| Step | State |
|---|---|
| Wake blink | In. Dark, a slit of light, dark, then the floor line. Skipped when the hour is already cleared |
| Till keypad | On the front of the till. Use from behind says the keypad is on the other side. The screen panel does not open |
| Abandonment | First pass only. Ceiling lamp and cabinets are duller. Dirt is not baked in Blender yet |
| Bed | `audio/lounge/bed.wav`, looping, quiet, starts with the room |
| One-shots | Pin, coins, reel click, till click, chain. `win.wav` is not used |
| Three notes | `audio/lounge/house_line.wav`, once, the first time the house line is read |
| Dim on fuse | Ceiling lamp, fill, and ambient drop. Restored if the fuse was already taken |
| Seen reads | Notebook, house line, notice, and slip speak on a large line while you are still looking |
| Door | Chain is the loudest one-shot. The bed is not stopped for the end card |

A played hour is the check. Listen at the bed, the pay, the fuse, and the chain before calling the plan done.

Later rooms copy these laws. They do not copy the lounge's three notes or the lantern hum.
