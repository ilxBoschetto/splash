import swaggerJSDoc from "swagger-jsdoc";

export const swaggerSpec = swaggerJSDoc({
  definition: {
    openapi: "3.0.3",
    info: {
      title: "My API Documentation",
      version: "1.0.0",
      description: "Documentazione delle API backend",
    },
    servers: [
      {
        url: process.env.BASE_URL || "http://localhost:3000",
      },
    ],
  },
  apis: ["./pages/api/**/*.ts"],
});
