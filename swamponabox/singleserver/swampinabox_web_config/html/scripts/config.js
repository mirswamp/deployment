/******************************************************************************\
|                                                                              |
|                                    config.js                                 |
|                                                                              |
|******************************************************************************|
|                                                                              |
|        This config provides a way to share configuration information.        |
|                                                                              |
|******************************************************************************|
|            Copyright (c) 2013 SWAMP - Software Assurance Marketplace         |
\******************************************************************************/


define([
], function() {
    return {

        // development web services
        //
		servers: {
			rws: 'https://HOSTNAME/swamp-web-server/public',
			csa: 'https://HOSTNAME/swamp-web-server/public',
		},

        // cookie for storing user session
        //
		cookie: {
			'name': "swampuuid",

			// the major domain to communicate across
			//
			'domain': null,
			'path': '/',
			'secure': true
		},

		// options flags
		//
		options: {
			assessments: {
				allow_multiple_tool_selection: true,
				allow_viewing_zero_weaknesses: true
			},
		}
    };
});

