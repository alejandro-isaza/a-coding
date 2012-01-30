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