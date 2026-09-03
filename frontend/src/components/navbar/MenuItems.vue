<template>
  <template
    :key="item.index"
    v-for="item in allNavItems">
    <a
      v-if="!item.items"
      :href="item.index">
      <el-menu-item
        :index="item.index"
        :class="item.class"
        :style="item.style">
        {{ item.title }}
      </el-menu-item>
    </a>
    <el-sub-menu
      v-else
      :index="item.index"
      :popper-class="item.popperClass"
      :class="item.class">
      <template #title>
        {{ item.title }}
      </template>
      <template
        :key="subItem.index"
        v-for="subItem in item.items">
        <a
          :href="subItem.index"
          :target="subItem.target"
          v-if="subItem.condition">
          <el-menu-item
            :class="subItem.class"
            :style="subItem.style"
            :index="subItem.index">
            <!-- subItem.component -->
            <component :is="subItem.component" />
          </el-menu-item>
        </a>
      </template>
    </el-sub-menu>
  </template>

  <!-- more -->
  <el-sub-menu
    v-if="moreItems.length > 0"
    :index="'more'"
    :popper-class="popperClass"
    :class="subMenuClass"
    :expand-close-icon="null"
    :expand-open-icon="null"
    style="--el-menu-icon-width: 0px">
    <template #title>
      <SvgIcon
        name="more_menu"
        class="p-1" />
      {{ $t('navbar.more') }}
    </template>

    <template
      :key="item.index"
      v-for="item in moreItems">
      <a
        v-if="!item.items"
        :href="item.index">
        <el-menu-item
          :index="item.index"
          :class="item.class"
          :style="item.style">
          {{ item.title }}
        </el-menu-item>
      </a>
      <el-sub-menu
        v-else
        :index="item.index"
        :popper-class="item.popperClass"
        :class="item.class">
        <template #title>
          {{ item.title }}
        </template>
        <template
          :key="subItem.index"
          v-for="subItem in item.items">
          <a
            :href="subItem.index"
            :target="subItem.target"
            v-if="subItem.condition">
            <el-menu-item
              :class="subItem.class"
              :style="subItem.style"
              :index="subItem.index">
              <!-- subItem.component -->
              <component :is="subItem.component" />
            </el-menu-item>
          </a>
        </template>
      </el-sub-menu>
    </template>
  </el-sub-menu>

  <template v-if="!props.isLoggedInBoolean">
    <hr />
    <div class="hidden md:flex px-4 py-6 flex-col gap-3">
      <a
        href="/signup"
        class="btn btn-primary btn-lg">
        {{ $t('navbar.register') }}
      </a>
      <a
        href="/login"
        class="btn btn-secondary-gray btn-lg">
        {{ $t('navbar.login') }}
      </a>
    </div>
  </template>
</template>

<script setup>
  import { ref, watch, onMounted, onUnmounted, shallowRef } from 'vue'
  import Mcp from './menuItem/Mcp.vue'
  import McpTools from './menuItem/McpTools.vue'
  import Skill from './menuItem/Skill.vue'
  import { useI18n } from 'vue-i18n'

  const { t } = useI18n()

  const McpRef = shallowRef(Mcp)
  const McpToolsRef = shallowRef(McpTools)
  const SkillsRef = shallowRef(Skill)

  const props = defineProps({
    isLoggedInBoolean: Boolean,
    starChainUrl: String,
    hasEmail: Boolean
  })

  // Get enabled menus from global config
  const enabledMenusStr = typeof ENABLED_MENUS !== 'undefined' ? ENABLED_MENUS : 'models,datasets,mcp,skills,spaces,codes,collections,prompts'
  const enabledMenusSet = new Set(enabledMenusStr.split(',').map(item => item.trim()).filter(Boolean))

  const allRawNavItems = [
    {
      id: 'models',
      title: t('navbar.models'),
      index: '/models',
      class: menuItemClass,
      style: 'border:none; height: 46px; border-radius: 4px; padding: 12px 16px;',
    },
    {
      id: 'datasets',
      title: t('navbar.datasets'),
      index: '/datasets',
      class: menuItemClass,
      style: 'border:none; height: 46px; border-radius: 4px; padding: 12px 16px;',
    },
    {
      id: 'mcp',
      title: t('navbar.mcp'),
      index: '/mcp/servers',
      class: menuItemClass,
      style:
        'border:none; height: 46px; border-radius: 4px; padding: 12px 16px;',
      items: [
        {
          title: t('navbar.mcpText'),
          index: '/mcp/servers',
          class: subMenuItemClass,
          style: 'height: auto;',
          component: McpRef,
          target: '',
          condition: true,
        },
        {
          title: t('navbar.mcpTools'),
          index: '/mcp/servers/tools',
          class: subMenuItemClass,
          style: 'height: auto;',
          component: McpToolsRef,
          target: '',
          condition: true,
        }
      ]
    },
    {
      id: 'skills',
      title: t('navbar.skills'),
      index: '/skills',
      class: menuItemClass,
      style: 'border:none; height: 46px; border-radius: 4px; padding: 12px 16px;',
    },
    {
      id: 'spaces',
      title: t('navbar.spaces'),
      index: '/spaces',
      class: menuItemClass,
      style: 'border:none; height: 46px; border-radius: 4px; padding: 12px 16px;',
    },
    {
      id: 'codes',
      title: t('navbar.codes'),
      index: '/codes',
      class: menuItemClass,
      style: 'border:none; height: 46px; border-radius: 4px; padding: 12px 16px;',
    },
    {
      id: 'collections',
      title: t('collections.collection'),
      index: '/collections',
      class: menuItemClass,
      style: 'border:none; height: 46px; border-radius: 4px; padding: 12px 16px;',
    },
    {
      id: 'prompts',
      title: t('prompts.promptLibrary'),
      index: '/prompts/library',
      class: menuItemClass,
      style: 'border:none; height: 46px; border-radius: 4px; padding: 12px 16px;',
    }
  ]

  // Filter menu items based on enabled configuration
  const rawNavItems = allRawNavItems.filter(item => enabledMenusSet.has(item.id))

  const allNavItems = ref(rawNavItems)

  const moreItems = ref([])
  const currentScreenWidth = ref(window.innerWidth)

  const handleResize = () => {
    currentScreenWidth.value = window.innerWidth
  }

  onMounted(() => {
    window.addEventListener('resize', handleResize)
    if (window.innerWidth > 768) {
      initMenuItems()
    }
  })

  onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
  })

  watch(currentScreenWidth, (newVal) => {
    if (window.innerWidth > 768) {
      initMenuItems()
    }
  })

  const initMenuItems = () => {
    // const menuWidth = document.querySelector('#pc-menu')?.offsetWidth

    if (768 < window.innerWidth && window.innerWidth <= 1024) {
      allNavItems.value = rawNavItems.slice(0, 3)
      moreItems.value = rawNavItems.slice(3)
    }

    if (1024 < window.innerWidth && window.innerWidth <= 1280) {
      allNavItems.value = rawNavItems.slice(0, 5)
      moreItems.value = rawNavItems.slice(5)
    }

    if (window.innerWidth > 1280) {
      allNavItems.value = rawNavItems
      moreItems.value = []
    }
  }

  const menuItemClass =
    'md:!px-3 md:!py-4 md:!h-auto js-menu-item-width'
  const subMenuClass = 'md:!h-auto md:!py-4 js-menu-item-width'
  const subMenuItemClass = 'mx-3 md:mx-0 md:!px-3'
  const popperClass = 'popper-submenu'
</script>

<style scoped>
  :deep(.el-sub-menu__title) {
    /* padding: 16px; */
    color: var(--Gray-600);
  }
  :deep(.popper-submenu .el-menu) {
    min-width: 200px;
    padding: var(--el-menu-base-level-padding);
  }
  :deep(.popper-submenu .el-menu .el-menu-item) {
    font-size: 16px;
    font-weight: 400;
    height: 46px;
    line-height: 24px;
  }
  :deep(.el-menu-item):hover {
    background-color: var(--Gray-50) !important;
  }
</style>
