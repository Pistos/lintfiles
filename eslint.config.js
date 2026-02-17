import js from '@eslint/js'
import globals from 'globals'

import perfectionist from 'eslint-plugin-perfectionist'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import stylistic from '@stylistic/eslint-plugin'

import typescriptEslint from 'typescript-eslint'
import { defineConfig, globalIgnores } from 'eslint/config'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      js.configs.recommended,
      perfectionist.configs['recommended-alphabetical'],
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
      typescriptEslint.configs.recommended,
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
    },
    plugins: {
      '@stylistic': stylistic,
    },
    rules: {
      'no-useless-return': 'error',
      'sort-keys': ['warn', 'asc', {'allowLineSeparatedGroups': true}],
      'sort-vars': 'warn',

      'perfectionist/sort-imports': [
        'warn',
        {
          'newlinesBetween': 'ignore',
          'newlinesInside': 'ignore',
          'partitionByNewLine': true,
          'specialCharacters': 'trim',
        },
      ],
      'perfectionist/sort-jsx-props': 'warn',
      'perfectionist/sort-objects': [
        'warn',
        {
          'newlinesBetween': 'ignore',
          'newlinesInside': 'ignore',
          'partitionByNewLine': true,
        },
      ],
      'perfectionist/sort-union-types': [
        'warn',
        {
          'groups': [
            'unknown',
            'nullish',
          ],
        },
      ],

      '@stylistic/comma-dangle': [
        'warn',
        {
          'arrays': 'always-multiline',
          'objects': 'always-multiline',
          'imports': 'always-multiline',
          'exports': 'always-multiline',
          'functions': 'only-multiline',
          'importAttributes': 'always-multiline',
          'dynamicImports': 'always-multiline'
        }
      ],
      '@stylistic/eol-last': 'warn',
      '@stylistic/semi': ['warn', 'never'],
      '@stylistic/jsx-closing-bracket-location': 'warn',
      '@stylistic/jsx-first-prop-new-line': 'warn',
      '@stylistic/jsx-indent-props': ['warn', 2],
      '@stylistic/jsx-max-props-per-line': ['warn', {'maximum': 1, 'when': 'multiline'}],
      '@stylistic/max-len': ['warn', {'code': 160, 'ignoreComments': false}],
      '@stylistic/max-statements-per-line': ['error', {'max': 2}],
      '@stylistic/newline-per-chained-call': ['warn', {'ignoreChainWithDepth': 2}],
      '@stylistic/no-extra-semi': 'warn',
      '@stylistic/no-mixed-spaces-and-tabs': 'warn',
      '@stylistic/no-trailing-spaces': 'warn',

      '@typescript-eslint/consistent-type-imports': 'error',
    },
  },
])
