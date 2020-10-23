# Jojo training mode menu for FBNeo

This is the updated version of the jojo training mode with the new menu features. It includes everything the previous training modes had and much more. 

Developed specifically for JoJo's Bizarre Adventure (Japan 990913, NO CD) (jojobanr1) though other versions should work.

This script was designed for FBNeo and is NOT compatible with FBA-RR. However the basic features should work for MAME-RR as well.

It is still undergoing development so more features will be added in the future. If you find any bugs or have any feature requests DM Maxie#7777 on discord.

# Features

You can enable and disable the following system features:

- Music
- Gui (Simple and advanced)
- Health Refill
- Meter Refill
- Stand Gauge Refill
- Infinite Protection System (IPS)

## Guard Action

Can be used to perform the following actions on guard or after a delay:

- Push Block
- Guard Cancel

To use this feature when enabled use start and hold away from you to set your opponent into blocking mode. Once they block an attack they will automatically perform the selected guard action after the desired amount of frames.

## Air Tech

Air teching can be set to on or off with 5 options. Up/Neutral, Down, Away, Toward or Random with delay

## 0F Air Tech

If an opponent is falling and hit with a move that makes them land on their feet instead of their back, they can air tech on the same frame they are hit. Enable this option to make the opponent 0F Air Tech.

## Direct Control

Direct character control by holding start has been revamped to include buttons. You can use this to:

- Select your opponents character in the menu
- Hold a direction and let go of start to make them continue holding in that direction
- Turn on their stand

## Force Stand

The opponent will automatically turn their stand on or off. This can be used to practice stand break combos quicker. To refill your opponent stand gauge press Medium Kick while the menu is open.

## Reversal

The opponent will perform a move on the first available frame out of hitstun/blockstun or after teching/push blocking. The current implementation doesn't work with buffered inputs but will allow the following:

- A, B, C, S, A+B+C (Roll)
- Replay Recorded inputs
- Replay inputs from inputs.txt

Any empty inputs from the start of recordings will be removed to start performing the action on the first frame.

## Throw Tech

The opponent will automatically tech all throws.

## Record/Replay

Record your inputs and play them back. The default keys are set to medium kick and heavy kick but can be rebound in the menu. If you hold down the replay button it will be set to loop. If the menu option is set to replay P2, player 1's inputs will be translated to player 2. This can be used to record player 2's inputs without rebinding or using a separate control scheme.

Alternatively to recording/replaying you could use the following feature to play back inputs.

# Input playback

To perform tool assisted input playback either copy the inputs.txt file into your fba directory or create your own. 

The syntax for the inputs text is as follows:
- P1 = Start player 1's inputs (Only 1 player is required)
- P2 = Start player 2's inputs (Only 1 player is required)
- u = Up
- d = Down
- l = Left
- r = Right
- a = A
- b = B
- c = C
- s = S
- number = Repeat for x frames

Each new line is a frame of input unless specified with a number eg. 5 = nothing for 5 frames, da10 = down and A for 10 frames

Directions assume the player 1 is on the left and facing right, while player 2 is on the right facing left. The inputs will be 
flipped programmatically if players swap sides so there is no need to rewrite your input for each side.

To perform the input playback change one of the hotkeys in the system settings menu to "Input playback" and press the hotkey

## Hitboxes

To view live hitboxes in game enable the feature in the system options.

It currently has the following bugs:
- Does not adjust based on the zoom state
- Projectile active frames are not shown correctly

## Replay lua

To avoid desyncing issues a separate lua script has been included for viewing inputs and hitboxes in online replays. 

The script works for both live matches and recorded matches.

## Credits

Credits to Maxie and the HFTF Stardust Romhackers for the current version with menu features.

Credits to peon2 for programming, potatoboih for finding RAM values and Klofkac for the initial version.

Special Thanks to Zarythe for graphical design and all the beta testers.