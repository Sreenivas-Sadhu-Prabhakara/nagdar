package backend

import (
	"encoding/json"
	"math"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestEvaluate_WageNetOfRejects(t *testing.T) {
	// stitching: 120 done, 5 rejects @ ₹3 = 345 ; buttons: 200 @ ₹0.5 = 100. Total 445.
	in := Input{Worker: "Radha", Lines: []Line{
		{Category: "stitch", Qty: 120, Rejects: 5, Rate: 3},
		{Category: "button", Qty: 200, Rejects: 0, Rate: 0.5},
	}}
	r := Evaluate(in)
	if math.Abs(r.NetWage-445) > 1e-9 {
		t.Fatalf("netWage=%v want 445", r.NetWage)
	}
	if r.TotalPieces != 320 || r.TotalRejects != 5 {
		t.Fatalf("totals wrong: %+v", r)
	}
}

func TestValidate(t *testing.T) {
	if err := (Input{Worker: "A", Lines: []Line{{Category: "x", Qty: 10, Rate: 1}}}).Validate(); err != nil {
		t.Fatalf("valid rejected: %v", err)
	}
	for i, bad := range []Input{
		{Worker: "", Lines: []Line{{Qty: 1}}},
		{Worker: "A", Lines: nil},
		{Worker: "A", Lines: []Line{{Category: "x", Qty: 5, Rejects: 9, Rate: 1}}},
	} {
		if err := bad.Validate(); err == nil {
			t.Fatalf("bad %d accepted", i)
		}
	}
}

func TestEvaluateEndpoint(t *testing.T) {
	srv := NewServer(nil)
	body := `{"worker":"Radha","lines":[{"category":"stitch","qty":120,"rejects":5,"rate":3}]}`
	rec := httptest.NewRecorder()
	srv.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/evaluate", strings.NewReader(body)))
	if rec.Code != http.StatusOK {
		t.Fatalf("status %d", rec.Code)
	}
	var r Result
	json.Unmarshal(rec.Body.Bytes(), &r)
	if math.Abs(r.NetWage-345) > 1e-9 {
		t.Fatalf("netWage=%v want 345", r.NetWage)
	}
}
