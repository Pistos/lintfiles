import { defineConfig, globalIgnores } from 'eslint/config'

import lintfilesReactConfig from './index.react.js'

export default defineConfig([
  globalIgnores(['dist']),
  ...lintfilesReactConfig,
])
