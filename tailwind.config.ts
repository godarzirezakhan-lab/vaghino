import type { Config } from 'tailwindcss';
const config: Config = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: { extend: { colors: { ink: '#17152b', violet: '#7656e8', gold: '#e7bd72', paper: '#fbf8f2' }, boxShadow: { glow: '0 12px 40px rgba(118,86,232,.18)' } } },
  plugins: [],
};
export default config;
