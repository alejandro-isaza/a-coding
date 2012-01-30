#pragma once
#include <tr1/unordered_set>
#include <vector>
#include <cmath>

namespace ac {
	class grid_graph {
	public:
		typedef int cost_type;
		
		struct node {
			int col;
			int row;
			node() : col(), row() {}
			node(int c, int r) : col(c), row(r) {}
			bool operator==(const node& n) const {
				return col == n.col && row == n.row;
			}
		};
		
		struct node_hash : public std::unary_function<node, std::size_t> {
			std::size_t operator()(const node& n) const {
				std::tr1::hash<int> h;
				return h(n.col) ^ h(n.row);
			}
		};

		friend inline std::ostream& operator<<(std::ostream& os, const grid_graph::node& n) {
			return os << "{" << n.col << ", " << n.row << "}";
		}
		
	public:
		grid_graph(int col_count, int row_count) : _col_count(col_count), _row_count(row_count) {}
	
		int row_count() const { return _row_count; }
		int col_count() const { return _col_count; }
	
		// Returns a vector of all empty nodes adjacent to n
		std::vector<node> adjacent_nodes(const node& n) {
			std::vector<node> nodes;
			node new_node = n;
		
			new_node.col -= 1;
			if (!obstacle(new_node))
				nodes.push_back(new_node);

			new_node.col += 1;
			new_node.row -= 1;
			if (!obstacle(new_node))
				nodes.push_back(new_node);

			new_node.col += 1;
			new_node.row += 1;
			if (!obstacle(new_node))
				nodes.push_back(new_node);

			new_node.col -= 1;
			new_node.row += 1;
			if (!obstacle(new_node))
				nodes.push_back(new_node);
		
			return nodes;
		}
	
		// Returns the distance (cost) between two adjacent nodes
		cost_type cost(const node& n1, const node& n2) const {
			return std::abs(n2.col - n1.col) + std::abs(n2.row - n1.row);
		}
	
		// Sets or resets an obstacle
		void obstacle(const node& n, bool obstacle) { if (obstacle) _obstacles.insert(n); }
		bool obstacle(const node& n) const {
			// Pretend there are obstacles on every node outside the specified width and height
			if (n.row < 0 || n.row >= _row_count)
				return true;
			if (n.col < 0 || n.col >= _col_count)
				return true;
			
			return _obstacles.find(n) != _obstacles.end();
		}
	
	private:
		int _col_count;
		int _row_count;
		std::tr1::unordered_set<node, node_hash> _obstacles;
	};
}
