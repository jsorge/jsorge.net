module.exports = {
  content: [
    "./Resources/Views/*.leaf",
  ],
  darkMode: 'media',
  theme: {
    extend: {
      typography: (theme) => ({
        DEFAULT: {
          css: {
            fontSize: '1.125rem',
            lineHeight: '1.7',
            p: {
              'margin-top': '1em',
              'margin-bottom': '1em',
            },
            ol: {
              'margin-top': '1em',
              'margin-bottom': '1em',
            },
            ul: {
              'margin-top': '1em',
              'margin-bottom': '1em',
            },
            pre: null,
            code: null,
            'code::before': null,
            'code::after': null,
            'pre code': null,
            'pre code::before': null,
            'pre code::after': null,
            a: {
              color: '#e8804b',
            },
            h2: {
              'font-size': '1.5rem',
              'line-height': '1.3',
              'margin-top': '1.75em',
              'margin-bottom': '0.45em',
              color: '#e8804b',
            },
            h3: {
              'font-size': '1.25rem',
              'line-height': '1.4',
              'margin-top': '1.6em',
              'margin-bottom': '0.45em',
            }
          }
        }
      })
    }
  },
}
