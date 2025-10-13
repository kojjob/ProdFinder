// TailwindCSS Configuration for ProdFinder
// Apple-inspired design with dark mode support

module.exports = {
  darkMode: 'class', // Enable dark mode with class strategy (.dark on html/body)
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      // Apple-inspired color palette
      colors: {
        // Primary brand colors
        primary: {
          50: '#e6f2ff',
          100: '#cce5ff',
          200: '#99cbff',
          300: '#66b0ff',
          400: '#3396ff',
          500: '#007AFF', // Apple blue
          600: '#0062cc',
          700: '#004999',
          800: '#003166',
          900: '#001933',
        },
        // Secondary/gray colors optimized for both modes
        secondary: {
          50: '#f9fafb',
          100: '#f3f4f6',
          200: '#e5e7eb',
          300: '#d1d5db',
          400: '#9ca3af',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          800: '#1f2937',
          900: '#111827',
        },
        // Dark mode specific colors
        dark: {
          bg: '#000000',
          surface: '#1c1c1e',
          elevated: '#2c2c2e',
          text: '#ffffff',
          'text-secondary': '#aeaeb2',
          border: '#38383a',
        }
      },
      // Apple-inspired animations
      animation: {
        'fade-in': 'fadeIn 0.6s cubic-bezier(0.16, 1, 0.3, 1)',
        'fade-in-scale': 'fadeInScale 0.6s cubic-bezier(0.16, 1, 0.3, 1)',
        'slide-up': 'slideUp 0.5s cubic-bezier(0.16, 1, 0.3, 1)',
        'scale-pulse': 'scalePulse 2s cubic-bezier(0.16, 1, 0.3, 1) infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        fadeInScale: {
          '0%': { opacity: '0', transform: 'scale(0.95)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        scalePulse: {
          '0%, 100%': { transform: 'scale(1)' },
          '50%': { transform: 'scale(1.05)' },
        },
      },
      // Apple-inspired spacing
      spacing: {
        '18': '4.5rem',
        '22': '5.5rem',
        '30': '7.5rem',
      },
      // Apple-inspired border radius
      borderRadius: {
        '4xl': '2rem',
        '5xl': '2.5rem',
      },
      // Apple-inspired shadows
      boxShadow: {
        'soft': '0 2px 16px rgba(0, 0, 0, 0.06)',
        'soft-lg': '0 8px 32px rgba(0, 0, 0, 0.08)',
        'glow': '0 0 24px rgba(0, 122, 255, 0.3)',
        'glow-lg': '0 0 48px rgba(0, 122, 255, 0.4)',
        'dark-soft': '0 2px 16px rgba(0, 0, 0, 0.4)',
        'dark-soft-lg': '0 8px 32px rgba(0, 0, 0, 0.6)',
      },
      // Apple-inspired backdrop blur
      backdropBlur: {
        'xs': '2px',
        'sm': '4px',
        'md': '12px',
        'lg': '24px',
        'xl': '40px',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
