export default {
  async fetch(_: Request): Promise<Response> {
    return new Response("hello!");
  },
};
