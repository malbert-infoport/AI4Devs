// Karma configuration file, see link for more information
// https://karma-runner.github.io/1.0/config/configuration-file.html

/* eslint-env node */
/* eslint-disable no-var, prefer-arrow-callback */

module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-coverage'),
      // Plugin personalizado para filtrar warnings específicos
      {
        'reporter:filtered-console': ['type', FilteredConsoleReporter]
      }
    ],
    client: {
      jasmine: {
        // you can add configuration options for Jasmine here
      },
      clearContext: false // leave Jasmine Spec Runner output visible in browser
    },
    jasmineHtmlReporter: {
      suppressAll: true // removes the duplicated traces
    },
    coverageReporter: {
      dir: require('path').join(__dirname, './coverage/helix6-v2-front'),
      subdir: '.',
      reporters: [{ type: 'html' }, { type: 'text-summary' }]
    },
    reporters: ['progress', 'kjhtml', 'filtered-console'],
    browsers: ['Chrome'],
    restartOnFileChange: true,
    // Configuración para reducir logging de warnings del servidor Karma (404, etc)
    logLevel: config.LOG_ERROR,
    browserNoActivityTimeout: 60000,
    // Capturar solo warnings y errores de consola (ignora info/log)
    browserConsoleLogOptions: {
      level: 'warn',
      format: '%b %T: %m',
      terminal: false // Desactivamos el logging directo, lo manejará nuestro reporter
    },
    // Servir las fuentes de Phosphor desde node_modules para evitar 404
    files: [
      {
        pattern: 'node_modules/@phosphor-icons/web/src/**/*.{woff,woff2,ttf,svg}',
        included: false,
        served: true,
        watched: false
      }
    ],
    // Proxy para que las URLs /media/... apunten a las fuentes servidas
    proxies: {
      '/media/Phosphor.woff2': '/base/node_modules/@phosphor-icons/web/src/regular/Phosphor.woff2',
      '/media/Phosphor.woff': '/base/node_modules/@phosphor-icons/web/src/regular/Phosphor.woff',
      '/media/Phosphor.ttf': '/base/node_modules/@phosphor-icons/web/src/regular/Phosphor.ttf',
      '/media/Phosphor-Bold.woff2': '/base/node_modules/@phosphor-icons/web/src/bold/Phosphor-Bold.woff2',
      '/media/Phosphor-Bold.woff': '/base/node_modules/@phosphor-icons/web/src/bold/Phosphor-Bold.woff',
      '/media/Phosphor-Bold.ttf': '/base/node_modules/@phosphor-icons/web/src/bold/Phosphor-Bold.ttf',
      '/media/Phosphor-Fill.woff2': '/base/node_modules/@phosphor-icons/web/src/fill/Phosphor-Fill.woff2',
      '/media/Phosphor-Fill.woff': '/base/node_modules/@phosphor-icons/web/src/fill/Phosphor-Fill.woff',
      '/media/Phosphor-Fill.ttf': '/base/node_modules/@phosphor-icons/web/src/fill/Phosphor-Fill.ttf'
    }
  });
};

// Reporter personalizado para filtrar warnings específicos de Kendo Grid
function FilteredConsoleReporter(baseReporterDecorator, config, logger) {
  baseReporterDecorator(this);

  var log = logger.create('filtered-console');

  // Lista de patterns de warnings que queremos suprimir
  var suppressedWarnings = [
    /Locked columns feature requires all columns to have set width/i,
    /Sticky columns feature requires all columns to have set width/i
  ];

  this.onBrowserLog = function (browser, logMessage, type) {
    // Procesar solo errores y warnings (browserConsoleLogOptions.level='warn' filtra el resto)
    if (type === 'error') {
      log.error(logMessage);
      return;
    }

    if (type === 'warn' || type === 'warning') {
      var message = logMessage.toString();

      // Si el mensaje coincide con algún patrón suprimido, lo ignoramos
      var shouldSuppress = suppressedWarnings.some(function (pattern) {
        return pattern.test(message);
      });
      if (shouldSuppress) {
        return; // No mostrar este warning
      }

      log.warn(logMessage);
      return;
    }

    // Ignorar todo lo demás (info/log/debug ya no llegan por el filtro de nivel)
  };
}
