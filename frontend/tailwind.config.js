/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      maxWidth: {
        screen: '100vw',
      },
      width: {
        screen: '100vw',
      },
    },
  },
  plugins: [],
};
