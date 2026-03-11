import { defineConfig, globalIgnores } from 'eslint/config'

import lintfilesConfig from './index.js'

export default defineConfig([
  globalIgnores(['dist']),
  ...lintfilesConfig,
])
