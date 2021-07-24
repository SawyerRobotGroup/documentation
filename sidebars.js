module.exports = {
  someSidebar: {
    Docs: [
      "Home",

      "OnBoarding",
      "Setup",
      {
        type: "category",
        label: "Linux and Utils",
        items: ["linux/Linux", "linux/Git", "linux/Bash", "linux/Dart Scripting"],
      },
      {
        type: "category",
        label: "Agents",
        items: [
          "agents/Agents",
          {
            type: "category",
            label: "Python",
            items: ["agents/python/Python", "agents/python/Game Engine", "agents/python/Markov MongoDB"],
          },
          "agents/C++ SSharp",
          "agents/Concepts",
          "agents/Markov Game",
        ],
      },
      {
        type: "category",
        label: "Flutter",
        items: [
          "flutter/Flutter",
          {
            type: "category",
            label: "Architecture",
            items: [
              "flutter/Architecture",
              "flutter/architecture/Change Notifier",
              "flutter/architecture/Dependency Injection",
              "flutter/architecture/State Notifier",
            ],
          },
          "flutter/Code Standard",
          "flutter/Install",
          "flutter/Packages",
          "flutter/Resources",
        ],
      },
      {
        type: "category",
        label: "Games",
        items: [
          "games/Games",
          {
            type: "category",
            label: "Block Game",
            items: [
              "games/block_game/Block Game",
              "games/block_game/Framework",
              "games/block_game/AI vs AI",
              "games/block_game/Human vs AI",
              "games/block_game/Human vs Human",
            ],
          },
          {
            type: "category",
            label: "Colored Trails",
            items: [
              "games/colored_trails/Colored Trails",
              "games/colored_trails/Framework",
              "games/colored_trails/Automatic Mode",
              "games/colored_trails/Manual Mode",
              "games/colored_trails/Further Readings",
            ],
          },
        ],
      },
      {
        type: "category",
        label: "ROS",
        items: ["ros/ROS", "ros/Install", "ros/Basics", "ros/Network"],
      },
      {
        type: "category",
        label: "Robots",
        items: ["robots/Manipulation"],
      },
      {
        type: "category",
        label: "Tiborg",
        items: ["tiborg/Tiborg", "tiborg/Tiborg Tutorials", "tiborg/MoveIt"],
      },
      {
        type: "category",
        label: "Qiborg",
        items: ["qiborg/Qiborg", "qiborg/Qiborg Tutorials"],
      },
      {
        type: "category",
        label: "System",
        items: [
          "system/System Organization",
          "system/System Requirements",
          {
            type: "category",
            label: "Speech",
            items: ["system/speech/Speech", "system/speech/Mic", "system/speech/Speech App"],
          },
          "system/Control Panel",
          "system/Control UI",
          "system/Faces",
          "system/Manipulation",
          "system/Vision",
        ],
      },
      {
        type: "category",
        label: "Documentation",
        items: [
          "documentation/Documentation",
          "documentation/doc1",
          "documentation/doc2",
          "documentation/doc3",
          "documentation/mdx",
        ],
      },
    ],
  },
};
