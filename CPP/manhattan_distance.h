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

#pragma once
#include "grid_graph.h"
#include <functional>
#include <cmath>

namespace ac {
	class manhattan_distance : public std::binary_function<grid_graph::node, grid_graph::node, int> {
	public:
		int operator()(const grid_graph::node& n1, const grid_graph::node& n2) const {
			return std::abs(n2.col - n1.col) + std::abs(n2.row - n1.row);
		}
	};
}