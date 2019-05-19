<?php


class AtomicRoute
{
    public $start;
    public $end;
    public $distance;


    public function __construct($start, $end)
    {
        $this->start = $start;
        $this->end = $end;
    }

    public function setDistance($distance)
    {
        $this->distance = $distance;
    }

    public function __toString()
    {
        return "{$this->start} ⟶ {$this->end} {$this->distance} km";
    }


}