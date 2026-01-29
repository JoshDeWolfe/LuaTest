Made using MVVM design pattern:

When the gameState is created, it creates the Player and enemies
The gameStateModel determines how and where enemies are generated, as well as the background graphics

Actors are composed of:
- A controller, which creates and hooks up the necessary components
- An actorModel, which handles gameplay data and functions
- An actorView, which handles the display of actors based on their current actorModel

The UIController:
- Creates, and knows about all other UI widgets (but they don't know about the UIController)
- Stores a reference to the current gameState, and handles binding

The Health Bar:
- Binds to an actorModel when it's created
- Whenever the actor's hp changes, The healthBarViewModel updates
- The healthBarView draws the healthBar based on the parameters in the healthBarViewModel


https://github.com/user-attachments/assets/dcefad8d-afef-49a6-aba7-3e16e41b351d
