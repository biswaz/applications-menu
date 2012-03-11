// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
//  
//  Copyright (C) 2011 Slingshot Developers
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using GLib;
using Gtk;
using Cairo;

namespace Slingshot {

    class Utils : GLib.Object {

        public static Alignment set_padding (Gtk.Widget widget, int top, 
                                             int right, int bottom, int left) {

            var alignment = new Alignment (0.0f, 0.0f, 1.0f, 1.0f);
            alignment.top_padding = top;
            alignment.right_padding = right;
            alignment.bottom_padding = bottom;
            alignment.left_padding = left;

            alignment.add (widget);
            return alignment;

        }
  
        public static string truncate_text (string input, int icon_size) {
            
            string new_text;
            if (input.length > icon_size / 3) {
                new_text = input[0:icon_size / 3] + "...";
                return new_text;
            } else {
                return input;
            }

        }

        public static int sort_apps_by_popularity (Backend.App a, Backend.App b) {

            return (int) (b.popularity*1000 - a.popularity*1000);

        }

        public static int sort_apps_by_name (Backend.App a, Backend.App b) {

            return GLib.strcmp (a.name.down (), b.name.down ());

        }

        public static int sort_apps_by_relevancy (Backend.App a, Backend.App b) {

            return (int) (a.relevancy*1000 - b.relevancy*1000);

        }

    }	
	
}
		