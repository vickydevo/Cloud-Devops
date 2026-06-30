
---

## 1. Git Fork

**What it is:** A personal copy of someone else's project that lives on your GitHub account. It allows you to freely experiment without affecting the original project.

* **How to do it:** 1.  Navigate to the repository on GitHub.
2.  Click the **Fork** button in the top-right corner.
3.  GitHub will create a copy of that repo under your username.

---

## 2. Git Clone

**What it is:** This moves the project from the internet (GitHub) onto your local machine.

* **How to do it:**
1. On your forked page, click the green **Code** button and copy the URL.
2. Open your terminal/command prompt and type:


```bash
git clone https://github.com/YourUsername/repository-name.git

```


3. Enter the folder: `cd repository-name`



---

## 3. Change Branch

**What it is:** Branches are like parallel universes. You should always create a new branch for new features so the "Main" code stays clean and stable.

* **Create and switch to a new branch:**
```bash
git checkout -b feature-name

```


* **Switch back to an existing branch (like main):**
```bash
git checkout main

```



---

## 4. Merge

**What it is:** Taking the changes you made in your "Feature" branch and combining them back into your "Main" branch.

* **How to do it:**
1. First, switch to the branch you want to merge *into* (usually main):
```bash
git checkout main

```


2. Then, pull the changes from your feature branch:
```bash
git merge feature-name

```





---

### Summary Table

| Action | Where it happens | Purpose |
| --- | --- | --- |
| **Fork** | GitHub (Cloud) | Create your own copy of a repo. |
| **Clone** | Terminal (Local) | Download the repo to your computer. |
| **Branch** | Terminal (Local) | Create a safe space to work on a specific task. |
| **Merge** | Terminal (Local) | Combine your finished work into the main code. |

> **Pro Tip:** Before you merge, always run `git status` to make sure your "working tree is clean"—meaning you've committed all your latest changes!
