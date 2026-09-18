# Using VS Code with the Ruby for Good WSL environment

The recommended editor setup is Visual Studio Code on Windows with the **Remote - WSL** extension. VS Code runs its user interface on Windows while running the project tools, Ruby, Node, Git, and Rails inside WSL.

## Prerequisites

1. Install [Visual Studio Code](https://code.visualstudio.com/) on Windows.
2. Install the **Remote - WSL** extension by Microsoft.
3. Import and start the Ruby for Good WSL distribution.
4. Complete the first-run setup, including GitHub authentication and repository selection.

Do not install a second copy of VS Code inside WSL. Install VS Code on Windows and use the Remote - WSL extension.

## Open a repository from WSL

From the WSL terminal, change into a cloned repository:

```bash
cd ~/src/<repository-name>
```

Then open the directory in VS Code:

```bash
code .
```

The first time this is run, VS Code installs its WSL-side server automatically. This may take a few moments.

The lower-left corner of VS Code should show a remote indicator such as:

```text
WSL: Ubuntu
```

This confirms that the folder and its tools are running inside WSL.

## Open a repository from VS Code

You can also:

1. Open VS Code on Windows.
2. Press `Ctrl+Shift+P`.
3. Run **WSL: Connect to WSL**.
4. Choose the Ruby for Good WSL distribution.
5. Choose **File > Open Folder**.
6. Open the repository under:

   ```text
   /home/dev/src/<repository-name>
   ```

Use the Linux path shown above rather than a Windows path under `C:\...`.

## Recommended extensions

Install project-specific extensions in the WSL environment, not only on the Windows side. Useful extensions may include:

- Ruby LSP
- Ruby
- Rails
- ESLint
- Prettier
- GitLens

When prompted, choose **Install in WSL**.

## Run project commands

Open the integrated terminal with:

```text
Ctrl+`
```

The terminal should open in the WSL-backed environment. Commands such as these will then use the tools installed in WSL:

```bash
ruby --version
bundle install
bin/rails db:prepare
bin/rails server
```

If PostgreSQL or MariaDB is needed, start it from the WSL terminal:

```bash
sudo service postgresql start
sudo service mariadb start
```

MariaDB's local `root` user has a blank password. The `dev` user has password
`password` and can create and manage databases.

## Troubleshooting

If `code .` does not work:

1. Confirm that VS Code is installed on Windows.
2. Confirm that the **Remote - WSL** extension is installed.
3. Close and reopen the WSL terminal after installing VS Code.
4. Verify that the `code` command is available:

   ```bash
   command -v code
   ```

If VS Code opens the folder on Windows instead of using WSL, run **WSL: Reopen Folder in WSL** from the Command Palette.

If the WSL-side server becomes unhealthy, run **WSL: Kill VS Code Server** from the Command Palette, then reopen the repository with:

```bash
code .
```