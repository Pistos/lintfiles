import globals from 'globals'

import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'

import baseConfig from './index.js'

export default [
  ...baseConfig,
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      globals: globals.browser,
    },
    rules: {
      'perfectionist/sort-jsx-props': 'warn',

      '@stylistic/jsx-closing-bracket-location': 'warn',
      '@stylistic/jsx-first-prop-new-line': 'warn',
      '@stylistic/jsx-indent-props': ['warn', 2],
      '@stylistic/jsx-max-props-per-line': ['warn', {'maximum': 1, 'when': 'multiline'}],
    },
  },
]
