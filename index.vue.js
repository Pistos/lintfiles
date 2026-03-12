import globals from 'globals'

import vue from 'eslint-plugin-vue'

import baseConfig from './index.js'

export default [
  ...baseConfig,
  ...vue.configs['flat/recommended'],
  {
    files: ['**/*.vue'],
    languageOptions: {
      globals: globals.browser,
    },
  },
]
