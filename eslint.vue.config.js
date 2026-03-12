import { defineConfig, globalIgnores } from 'eslint/config'

import lintfilesVueConfig from './index.vue.js'

export default defineConfig([
  globalIgnores(['dist']),
  ...lintfilesVueConfig,
])
