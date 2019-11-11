module.exports = {
  "env": {
    "browser": true,
    "es6": true,
    "node": true,
  },
  "extends": [
    "eslint:recommended",
    "plugin:vue/essential",
  ],
  "globals": {
    "Atomics": "readonly",
    "SharedArrayBuffer": "readonly",
  },
  "parserOptions": {
    "ecmaVersion": 2018,
    "parser": "babel-eslint",
    "sourceType": "module",
  },
  "plugins": [
    "vue",
  ],
  "rules": {
    "brace-style": [
      "error",
    ],
    "comma-dangle": [
      "error",
      "always-multiline",
    ],
    "eol-last": [
      "error",
      "always",
    ],
    "indent": [
      "warn",
      2,
      {
        "ArrayExpression": 1,
        "ImportDeclaration": 1,
        "ObjectExpression": 1,
        "SwitchCase": 1,
      },
    ],
    "key-spacing": [
      "error",
      {
        "afterColon": true,
        "beforeColon": false,
        "mode": "strict",
      },
    ],
    "keyword-spacing": [
      "error",
    ],
    "linebreak-style": [
      "error",
      "unix",
    ],
    "max-len": [
      "error",
      {
        "code": 120,
      },
    ],
    "max-lines-per-function": [
      "warn",
      {
        "max": 48,
        "skipBlankLines": true,
        "skipComments": true,
      },
    ],
    "max-statements": [
      "warn",
      32
    ],
    "max-statements-per-line": [
      "error",
      {
        "max": 1,
      },
    ],
    "no-invalid-this": [
      "error",
    ],
    "no-negated-condition": [
      "error",
    ],
    "no-return-assign": [
      "error",
      "always",
    ],
    "no-tabs": [
      "error",
    ],
    "no-trailing-spaces": [
      "error",
    ],
    "no-unused-expressions": [
      "warn",
    ],
    "no-useless-return": [
      "error",
    ],
    "no-var": [
      "error",
    ],
    "quotes": [
      "warn",
      "single",
    ],
    "radix": [
      "error",
      "always",
    ],
    "semi": [
      "error",
      "never",
    ],
    "sort-keys": [
      "error",
    ],
    "space-before-function-paren": [
      "error",
      "always",
      ],
    "spaced-comment": [
      "error",
      "always",
    ]
  }
}
