# output as png image
	set terminal png size 1024,768 crop

	# save file to benchmark.png
	set output "merged_values.png"

	# graph a title
	set title "Merged Test Results"

	# nicer aspect ratio for image size
	set size 1,0.7

	# y-axis grid
	set grid y

	# x-axis label
	set xlabel "Requests"

	# y-axis label
	set ylabel "Response time \(ms\)"

  set pointsize 1

  plot "/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-11-58/values.tsv" using 9 smooth sbezier with lines title "localhost:12080 - 2024-12-06-00-11-58","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-12-07/values.tsv" using 9 smooth sbezier with lines title "localhost:12080 - 2024-12-06-00-12-07","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-12-14/values.tsv" using 9 smooth sbezier with lines title "localhost:12080 - 2024-12-06-00-12-14","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-12-21/values.tsv" using 9 smooth sbezier with lines title "localhost:12080 - 2024-12-06-00-12-21","/home/des/Projects/apachebench-graphs/results/localhost:12080/2024-12-06-00-12-28/values.tsv" using 9 smooth sbezier with lines title "localhost:12080 - 2024-12-06-00-12-28",
