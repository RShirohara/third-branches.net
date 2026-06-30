import { defineConfig } from "vitepress";

// Ref: <https://vitepress.dev/reference/site-config>
export default defineConfig({
  title: "第三支流",
  lang: "ja-JP",
  themeConfig: {
    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/RShirohara/third-branches.net",
      },
    ],
    sidebar: [
      {
        text: "身分証明",
        collapsed: false,
        items: [
          {
            text: "Ray Shirohara (城原 零)",
            link: "/identities/ray-shirohara",
          },
          {
            text: "Rei Shiroto (白戸 レイ)",
            link: "/identities/rei-shiroto",
          },
        ],
      },
    ],
    docFooter: {
      prev: false,
      next: false,
    },
  },
  outDir: "../../dist/website",
  lastUpdated: true,
});
