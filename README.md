# ELP_Elm - Projet Elm

Ce projet est une implémentation de la bibliothèque Python `Turtle`, réécrite en langage fonctionnel **Elm**.

## Fonctionnalités

Vous pouvez dessiner des figures en utilisant les instructions suivantes :
- **Repeat** : Répète un ensemble d'instructions.
- **Forward** : Avance d'une certaine distance.
- **LeftTurn** : Effectue une rotation vers la gauche.
- **RightTurn** : Effectue une rotation vers la droite.

### Exemple d'entrée

Voici un exemple d'instructions permettant de dessiner une figure :

```elm
[
  Repeat 2 [Forward 100, LeftTurn 90, Forward 50, LeftTurn 90],
  Forward 20,
  Repeat 36 [Forward 5, RightTurn 10],
  Forward 60,
  Repeat 36 [Forward 5, RightTurn 10]
]
```

Ce projet se compile à partir du fichier Main.elm en utilisant la commande :

elm make src/Main.elm --output=main.html 

Enfin ce projet contient une version deja compilé accesible à la racine du projet via Main.html