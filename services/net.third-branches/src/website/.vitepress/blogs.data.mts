import path from "node:path";
import { createContentLoader } from "vitepress";

interface Blog {
  text: string;
  link: string;
}
declare const data: Blog[];

export { data };

export default createContentLoader("blogs/*.md", {
  transform(rawData) {
    return rawData.map((data) => {
      const parsedPath = path.parse(data.url);
      return {
        text: parsedPath.name.replace("_", " "),
        link: `/blogs/${parsedPath.name}`,
      };
    });
  },
});
