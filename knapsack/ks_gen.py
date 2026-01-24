from argparse import ArgumentParser
from random import randint

if __name__ == "__main__":
	parser = ArgumentParser()
	parser.add_argument("n_items", type=int)
	args = parser.parse_args()

	# given n_items.
	# v and w will be in [1, n_items].
	# say we want a solution of size ~n_items / 2.
	# E[w] = (n_items + 1) / 2
	# capacity then should be E[w] * (n_items / 2).

	capacity = (args.n_items + 1) * args.n_items // 4

	print(args.n_items)
	for i in range(args.n_items):
		v = randint(1, args.n_items)
		w = randint(1, args.n_items)
		print(f"{i+1}  {v}  {w}")
	print(capacity)
