import { defineConfig } from "vitepress";

// Ref: <https://vitepress.dev/reference/site-config>
export default defineConfig({
  title: "第三支流",
  lang: "ja-JP",
  outDir: "../../dist/website",
  lastUpdated: true,
  markdown: {
    breaks: true,
  },
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
      {
        text: "記事",
        collapsed: false,
        items: [
          {
            text: "2026",
            items: [
              {
                text: "2026-01-18: 一行艦娘",
                link: "/blogs/20260118T144027_b9b1e8f7-090d-467b-9662-649b1f7d9a8a",
              },
            ],
          },
        ],
      },
    ],
    docFooter: {
      prev: false,
      next: false,
    },
  },
});
