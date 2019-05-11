# QTable
An interactive Q Table program to help teach reinforcement learning

# Editor Controls
Arrow Keys: Changes map size
PageUp: Cycles tool forward
PageDown: Cycles tool backward

# Editor UI
Discount: How much value an item retains over each square. A value closer to 1 means that items barely lose value over distance while a value close to 0 means that items will lose value over distance quickly.
Learning Rate: How much the agent values new information over old information.
Numtrain: The number of times the agent will train before displaying results to the user.

# Editor Tools
Items: Items consist of the diamond, emerald, coin, and fire. Items can be given a value with the value painter to add rewards and penalties to the map.
Walls: There are two walls, right and down. Placing a right wall also places a left wall in the square to the right, and placing a down wall also places an up wall in the square below.
Agent: The agent is represented by a rounded purple square. Setting the agent position sets the position where the agent will start when running the game. There can only be one agent at a time. 
Win or Loss: The small flag can be placed over any tile to make that tile end the the game when the agent reaches it.
Erasers: Each eraser can erase the map items that are shown on the eraser.
Value Painter: The value painter displays the current values of all items and adds a UI element at the top left to set the value of the cursor. After the cursor value is set, click an item to set its value.

# Note: All enclosed spaces in the map must have at least one win or loss state!
