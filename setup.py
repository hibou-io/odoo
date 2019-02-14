#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import find_packages, setup
from os.path import join, dirname


exec(open(join(dirname(__file__), 'odoo', 'release.py'), 'rb').read())  # Load release variables
lib_name = 'odoo'

setup(
    name='odoo',
    version=version,
    description=description,
    long_description=long_desc,
    url=url,
    author=author,
    author_email=author_email,
    classifiers=[c for c in classifiers.split('\n') if c],
    license=license,
    scripts=['setup/odoo'],
    packages=find_packages(),
    package_dir={'%s' % lib_name: 'odoo'},
    include_package_data=True,
    install_requires=[
        'babel >= 1.0',
        'decorator',
        'docutils',
        'feedparser',
        'gevent',
        'html2text',
        'Jinja2',
        'lxml < 4.3.0',  # windows binary http://www.lfd.uci.edu/~gohlke/pythonlibs/
        'mako',
        'mock',
        'ofxparse',
        'passlib',
        'pillow',  # windows binary http://www.lfd.uci.edu/~gohlke/pythonlibs/
        'psutil',  # windows binary code.google.com/p/psutil/downloads/list
        'psycopg2 >= 2.2',
        'pydot',
        'pyldap',  # optional
        'pyparsing',
        'pypdf2',
        'pyserial',
        'python-dateutil',
        'pytz',
        'pyusb >= 1.0.0b1',
        'pyyaml',
        'qrcode',
        'reportlab',  # windows binary pypi.python.org/pypi/reportlab
        'requests',
        'suds-jurko',
        'vatnumber',
        'vobject',
        'werkzeug',
        'xlsxwriter',
        'xlwt',
        #  Hibou Odoo
        'cachetools <= 2.9.9',  #  used by OCA Connector (e.g. Magento Connector) .. 3.0.0 was tested and not working 2018/12/20
        'cryptography',
        'magento',  #  connector_magento
        'markdown',  #  Hibou Odoo Suite `timesheet_description`
        'newrelic',  #  Hibou Odoo Suite `newrelic`
        'num2words',  #  odoo core check printing etc.
        'phonenumbers',  #  odoo core
        'pyOpenSSL',
        'pycryptodome',
        'uszipcode',  # Hibou Odoo Suite `l10n_us_partner_zipcode`, `sale_planner`
        'watchdog',
        'xlrd',  #  read MS Excel files
        'xlwt',  #  write MS Excel files
    ],
    python_requires='>=3.5',
    extras_require={
        'SSL': ['pyopenssl'],
    },
    tests_require=[
        'mock',
    ],
)
