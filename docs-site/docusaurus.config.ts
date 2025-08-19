import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: 'Flutter SuperApp Architecture',
  tagline: 'Modular Architecture for Scalable Cross-Platform Apps',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://flutter-superapp-docs.web.app',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'claysol',
  projectName: 'flutter-superapp-docs',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl:
            'https://github.com/claysol/flutter-superapp/tree/main/docs-site/',
        },
        blog: {
          showReadingTime: true,

          editUrl:
            'https://github.com/claysol/flutter-superapp/tree/main/docs-site/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    image: 'img/docusaurus-social-card.jpg',
    navbar: {
      title: 'Flutter SuperApp',
      logo: {
        alt: 'Flutter SuperApp Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Architecture Guide',
        },
        {
          href: 'https://github.com/claysol/flutter-superapp',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {
              label: 'Architecture Overview',
              to: '/docs/architecture/overview',
            },
            {
              label: 'Module Development',
              to: '/docs/modules/creating-modules',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'Stack Overflow',
              href: 'https://stackoverflow.com/questions/tagged/flutter-superapp',
            },
            {
              label: 'Discord',
              href: 'https://discordapp.com/invite/flutter',
            },
            {
              label: 'Twitter',
              href: 'https://twitter.com/flutterdev',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Blog',
              to: '/blog',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/claysol/flutter-superapp',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Geojit. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart', 'yaml'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
