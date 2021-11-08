---
sidebar_position: 4
---

# FAQ

## What is Stitch?
**Stitch** is a simple and powerful [Entity Component System (ECS)](https://en.wikipedia.org/wiki/Entity_component_system) built specifically for Roblox game development. 

Stitch allows you to separate the **data** and **behavior** of things in your game. This means your code will be easier to understand and update, and more performant.

## Why should I use an ECS over Object-Oriented Programming (OOP)?
Using an ECS can save you from complex code that arises due to the [diamond inheritance problem](https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem) in large object-oriented games. Using OOP, you will likely run into scenarios where the diamond problem is impossible to avoid without structuring your entire game. ECS solves this issue by removing inheritance altogether - instead, you compose many different components on a single entity. This makes it easy to grow your codebase and rapidly add new features.

However, ECS and OOP aren't mutually exclusive - you can (and should!) use a mix of both when it's easier.

## I have a question not on this page!
Awesome! Feel free to message me on Discord (sayhisam1#7705), or make an issue on the repository with your question.