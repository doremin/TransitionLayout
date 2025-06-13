# TransitionLayout Demo (Pinch-to-Zoom Grid)

A UIKit demo project implementing a **pinch-to-zoom style grid transition** like Line iOS Application using `UICollectionViewTransitionLayout`.

📘 [What is Transition Layout?](https://doremin.github.io/2025-06-11/13-07)

---

## ✨ Features

- 📏 Pinch gesture controls column count dynamically
- 🎛 Smooth interactive layout transition using `UICollectionViewTransitionLayout`
- 📐 Layout change based on `log2(scale)` for linear control

## 🎯 Why log2(scale)?

The raw gesture scale is:

- 1.0 → 2.0 → 4.0 → 8.0 (zoom in)
- 1.0 → 0.5 → 0.25 → 0.125 (zoom out)

But by applying log2(scale), we turn it into:

- log2(2.0) = 1
- log2(0.5) = -1

## LINE vs This Project

**LINE**
![LINE](/resources/line.gif)
**This Project**
![DEMO](/resources/demo.gif)
