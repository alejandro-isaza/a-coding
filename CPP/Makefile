LIBS = -L/opt/local/lib
CXXFLAGS = -I. -Wall -ggdb -O0
BUILDDIR = bin
TEST_OBJS = bin/test_runner.o bin/grid_graph_test.o bin/astar_test.o bin/open_list_test.o
TEST_SRCS = test/test_runner.cpp test/grid_graph_test.cpp test/astar_test.cpp test/open_list_test.cpp

.PHONY: all test
all: test
test: bin/test
	./bin/test

bin/astar_test.o: astar.h grid_graph.h manhattan_distance.h bimap_open_list.h property_map_open_list.h
bin/grid_graph_test.o: grid_graph.h
bin/open_list_test.o: grid_graph.h grid_graph.h bimap_open_list.h property_map_open_list.h

bin/test: $(TEST_OBJS)
	$(CXX) $(TEST_OBJS) -lboost_unit_test_framework -o $@

bin/%.o: test/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean
clean:
	$(RM) -f $(TEST_OBJS) bin/test
