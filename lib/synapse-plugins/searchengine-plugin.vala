/*
* Copyright (c) 2017 biswaz
*               2017 elementary LLC.
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: biswaz
*/

namespace Synapse {
    public class SearchenginePlugin: Object, Activatable, ItemProvider {

        public bool enabled { get; set; default = true; }

        public void activate () { }

        public void deactivate () { }

        public class Result : Object, Match {
            // from Match interface
            public string title { get; construct set; }
            public string description { get; set; }
            public string icon_name { get; construct set; }
            public bool has_thumbnail { get; construct set; }
            public string thumbnail_path { get; construct set; }
            public MatchType match_type { get; construct set; }

            public int default_relevancy { get; set; default = 0; }

            private AppInfo? appinfo;
            private string search_term;

            public Result (string search) {
                search_term = search;

                string _title = "";
                string _icon_name = "";

                appinfo = AppInfo.get_default_for_type ("text/html", false); //This gets the default browser set using switchboard settings
                if (appinfo != null) {
                    // TRANSLATORS: The first %s is what the user searched for, the second will be replaced with the localized name of the browser
                    _title = _("Search for %s in %s".printf (search_term, appinfo.get_display_name ()));
                    _icon_name = appinfo.get_icon ().to_string ();
                }

                this.title = _title;
                this.icon_name = _icon_name;
                this.description = _("Search online");
                this.has_thumbnail = false;
                this.match_type = MatchType.ACTION;
            }

            public void execute (Match? match) {
                if (appinfo == null) {
                    return;
                }

                var list = new List<string> ();
                list.append ("https://www.google.com/search?q=" + Uri.escape_string (search_term));

                try {
                    appinfo.launch_uris (list, null);
                } catch (Error e) {
                    warning ("%s\n", e.message);
                }
            }        
        }

        private static AppInfo? appinfo;
        private static Regex regex;

        static void register_plugin () {
            bool browser_installed = false;

            appinfo = AppInfo.get_default_for_type ("text/html", false);
            // Only register the plugin if we have an application that supports text/html
            if (appinfo != null) {
                browser_installed = true;
            }

            DataSink.PluginRegistry.get_default ().register_plugin (typeof (SearchenginePlugin),
                                            _("Search online"),
                                            _("Opens search engine with the given search term"),
                                            "system-software-install",
                                            register_plugin,
                                            browser_installed,
                                            _("Browser is not installed"));
        }

        static construct {
            register_plugin ();
            
            try {
                // 2 or more characters, must contain at least one letter
                regex = new Regex ("""^(?=\pL).{2,}$""", RegexCompileFlags.OPTIMIZE);
            } catch (Error e) {
                error ("Error creating regexp.");
            }
        }

        public bool handles_query (Query query) {
            return QueryFlags.TEXT in query.query_type;
        }

        public async ResultSet? search (Query query) throws SearchError {
            if (regex.match (query.query_string)) {
                ResultSet results = new ResultSet ();
                Result search_result = new Result (query.query_string);
                results.add (search_result, Match.Score.INCREMENT_MINOR);

                return results;
            } else {
                return null;
            }
        }
    }
}
