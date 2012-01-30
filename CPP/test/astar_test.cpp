//  Copyright 2011 Alejandro Isaza.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.

#include "astar.h"
#include "bimap_open_list.h"
#include "grid_graph.h"
#include "manhattan_distance.h"
#include "property_map_open_list.h"

#include <boost/mpl/list.hpp>
#include <boost/test/unit_test.hpp>
#include <iostream>
#include <sys/time.h>

namespace ac {
	typedef grid_graph::node node;
	typedef grid_graph::node_hash node_hash;
	typedef grid_graph::cost_type cost;
	typedef bimap_open_list<node, node_hash, cost> bimap;
	typedef property_map_open_list<node, node_hash, cost> property;
	typedef boost::mpl::list<bimap, property> open_list_types;
	
	struct astar_test_fixture {
	};
	
	BOOST_FIXTURE_TEST_SUITE(astar_test, astar_test_fixture);
	
	BOOST_AUTO_TEST_CASE_TEMPLATE(basic_search, OL, open_list_types) {
		grid_graph g(5, 5);
		manhattan_distance h;
		astar<grid_graph, manhattan_distance, OL> obj(g, h);
		std::vector<node> path = obj.path(node(0,0), node(4,4));
		
		BOOST_CHECK_EQUAL(path.size(), 9);
	}
	
	BOOST_AUTO_TEST_SUITE_END();
}
