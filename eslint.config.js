const js = require("@eslint/js")
const globals = require("globals")

module.exports = [
  {
    ignores: ["node_modules/**", "coverage/**", "frontend/**"],
  },

  js.configs.recommended,

  {
    files: ["src/**/*.js", "tests/**/*.js", "*.js"],

    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "commonjs",

      globals: {
        ...globals.node,
        ...globals.jest,
      },
    },

    rules: {
      "no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
        },
      ],
    },
  },
]
