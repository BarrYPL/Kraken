# Kraken

<!-- Table of Contents -->
# :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
  * [Screenshots](#camera-screenshots)
  * [Tech Stack](#space_invader-tech-stack)
  * [Features](#dart-features)
- [Getting Started](#toolbox-getting-started)
  * [Prerequisites](#bangbang-prerequisites)
  * [Installation](#gear-installation)
- [Usage](#eyes-usage)
- [Roadmap](#compass-roadmap)

<!-- About the Project -->
## :star2: About the Project

Kraken is a project of simple pranking app and control panel for it. In the current version, the panel is displayed correctly only in the mobile version. The PC site will be added in the future. It is also planned to rewrite the frontend to ReactJS.
It is still early v0.9 but it's working.

<!-- Screenshots -->
### :camera: Screenshots

<div align="center"> 
  <img src="https://github.com/BarrYPL/Kraken/blob/main/public/images/Git%20Screens/ss4.png?raw=true" alt="screenshot" />
</div>


<!-- TechStack -->
### :space_invader: Tech Stack

<details>
  <summary>Client</summary>
  <ul>
    <li><a href="https://en.wikipedia.org/wiki/ANSI_C">ANSI C</a></li>
    <li><a href="https://learn.microsoft.com/en-us/windows/win32/apiindex/windows-api-list">WINAPI</a></li>
  </ul>
</details>

<details>
  <summary>Server</summary>
  <ul>
    <li><a href="https://www.ruby-lang.org/">Ruby</a></li>
    <li><a href="https://sinatrarb.com">Sinatra framework</a></li>
    <li><a href="https://www.sqlite.org/index.html">SQLite</a></li>    
    <li><a href="https://en.wikipedia.org/wiki/HTML">HTML</a></li>
    <li><a href="https://en.wikipedia.org/wiki/CSS">CSS</a></li>
    <li><a href="https://en.wikipedia.org/wiki/JavaScript">JavaScript</a></li>
  </ul>
</details>

### :dart: Features

- Get a Shell from targeted PC.
- Make pointer unable to use. (Random shaking all over the screen.)
- Melt screen
- Blue Screen Of Death (not Fake one)
- Volume control
- Trap on specified website title (closing it after 10s, Jira in my case.)
- Hiding Menu Start
- Replacing the contents of the clipboard when a specific window is detected. (Discord in my case.)
- Turn off monitor
- Swap mouse buttons
- Get webshell (It's not working well yet.)
- Generate customized errors

<div align="center"> 
  <img src="https://github.com/BarrYPL/Kraken/blob/main/public/images/Git%20Screens/ss3.png?raw=true" alt="screenshot" />
</div>

## 	:toolbox: Getting Started

Compile `kraken.c` file and `svchost.c` file, remember to replace IP to your server, pou them somehow on your server and run `oneliner.txt` from pranking PC to install those 2 apps. `Kraken` it is actual pranking software and `svchost` is it's guard making sure that Kraken is working and trying to restart him when he's not detected.

### :bangbang: Prerequisites

<p>Kraken require Windows 64-bit to function properly. It won't works on UNIX systems.
It is also required to have stable Internet connection between pranking PC and the server.

Server requires, DB Browser, instaled Ruby language and some other gems.</p>

### :gear: Installation

Download repo, change credentials in `init_db.rb` and run that file copy created DB to `/db` and run `main.rb` when gems are installed.

```bash
  git clone https://github.com/BarrYPL/Kraken.git
  cd db/db_components
  vim init_db.rb *edit credentials*
  cp database.db ../
  cd ../..
  ./main.rb
```

## :eyes: Usage

After logging in choose specified PC, click on "connect" button and pick an option you want to run on praking PC.

<div align="center"> 
  <img src="https://github.com/BarrYPL/Kraken/blob/main/public/images/Git%20Screens/ss1.png?raw=true" alt="screenshot" />
</div>

<div align="center"> 
  <img src="https://github.com/BarrYPL/Kraken/blob/main/public/images/Git%20Screens/ss2.png?raw=true" alt="screenshot" />
</div>

## :compass: Roadmap

* [ ] Add more features
* [ ] Make process harder to find
* [ ] Add Winapi Hooks


