import js from '@eslint/js'

import perfectionist from 'eslint-plugin-perfectionist'
import stylistic from '@stylistic/eslint-plugin'

import typescriptEslint from 'typescript-eslint'

export default [
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      js.configs.recommended,
      perfectionist.configs['recommended-alphabetical'],
      typescriptEslint.configs.recommended,
    ],
    languageOptions: {
      ecmaVersion: 2020,
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
          'dynamicImports': 'always-multiline',
          'exports': 'always-multiline',
          'functions': 'only-multiline',
          'importAttributes': 'always-multiline',
          'imports': 'always-multiline',
          'objects': 'always-multiline',
        },
      ],
      '@stylistic/eol-last': 'warn',
      '@stylistic/max-len': ['warn', {'code': 160, 'ignoreComments': false}],
      '@stylistic/max-statements-per-line': ['error', {'max': 2}],
      '@stylistic/newline-per-chained-call': ['warn', {'ignoreChainWithDepth': 2}],
      '@stylistic/no-extra-semi': 'warn',
      '@stylistic/no-mixed-spaces-and-tabs': 'warn',
      '@stylistic/no-trailing-spaces': 'warn',
      '@stylistic/semi': ['warn', 'never'],

      '@typescript-eslint/consistent-type-imports': 'error',
    },
  },
]
