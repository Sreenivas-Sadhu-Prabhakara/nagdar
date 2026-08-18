package backend

import "fmt"

// Line is one rate-category's output for a worker: pieces done at a per-piece
// rate, less rejects that aren't paid.
type Line struct {
	Category string  `json:"category"`
	Qty      int     `json:"qty"`
	Rejects  int     `json:"rejects"`
	Rate     float64 `json:"rate"`
}

// Input is a worker's piece-rate wage over a period, across rate-categories.
type Input struct {
	Worker string `json:"worker"`
	Lines  []Line `json:"lines"`
}

// LineResult is the computed pay for one line.
type LineResult struct {
	Category  string  `json:"category"`
	PaidQty   int     `json:"paidQty"`
	Amount    float64 `json:"amount"`
}

// Result is the wage slip.
type Result struct {
	Worker       string       `json:"worker"`
	Lines        []LineResult `json:"lines"`
	TotalPieces  int          `json:"totalPieces"`
	TotalRejects int          `json:"totalRejects"`
	NetWage      float64      `json:"netWage"`
}

// Headline is the net wage.
func (r Result) Headline() float64 { return r.NetWage }

// Label is the worker name.
func (r Result) Label() string { return r.Worker }

// Validate reports whether the Input is well formed.
func (in Input) Validate() error {
	if in.Worker == "" {
		return fmt.Errorf("worker is required")
	}
	if len(in.Lines) == 0 {
		return fmt.Errorf("at least one line is required")
	}
	for _, l := range in.Lines {
		if l.Qty < 0 || l.Rejects < 0 || l.Rate < 0 {
			return fmt.Errorf("quantities and rate cannot be negative")
		}
		if l.Rejects > l.Qty {
			return fmt.Errorf("rejects cannot exceed quantity in %q", l.Category)
		}
	}
	return nil
}

// Evaluate totals a worker's pay: each line pays (qty − rejects) × rate.
func Evaluate(in Input) Result {
	res := Result{Worker: in.Worker}
	for _, l := range in.Lines {
		paid := l.Qty - l.Rejects
		amt := float64(paid) * l.Rate
		res.Lines = append(res.Lines, LineResult{Category: l.Category, PaidQty: paid, Amount: amt})
		res.TotalPieces += l.Qty
		res.TotalRejects += l.Rejects
		res.NetWage += amt
	}
	return res
}
