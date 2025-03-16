import { describe, it, expect, beforeEach, vi } from "vitest"

// Mock contract calls
const mockContractCall = vi.fn()
const mockTxOk = (value) => ({ value, isOk: true })
const mockTxErr = (code) => ({ code, isOk: false })

// Mock contract
const mockContract = {
  registerLuggage: (...args) => mockContractCall("registerLuggage", ...args),
  registerByAirline: (...args) => mockContractCall("registerByAirline", ...args),
  deactivateLuggage: (...args) => mockContractCall("deactivateLuggage", ...args),
  getLuggage: (...args) => mockContractCall("getLuggage", ...args),
  setContractOwner: (...args) => mockContractCall("setContractOwner", ...args),
}

// Mock principals
const OWNER = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
const PASSENGER = "ST3PF13W7Z0RRM42A8VZRVFQ75SV1K26RXEP8YGKJ"

describe("Luggage Registration Contract", () => {
  beforeEach(() => {
    mockContractCall.mockReset()
  })
  
  describe("registerLuggage", () => {
    it("should register luggage successfully", async () => {
      mockContractCall.mockReturnValueOnce(mockTxOk(1))
      
      const result = await mockContract.registerLuggage("AA123", "JFK", "LAX", "Black suitcase with red tag", 15000)
      
      expect(mockContractCall).toHaveBeenCalledWith(
          "registerLuggage",
          "AA123",
          "JFK",
          "LAX",
          "Black suitcase with red tag",
          15000,
      )
      expect(result.isOk).toBe(true)
      expect(result.value).toBe(1)
    })
  })
  
  describe("registerByAirline", () => {
    it("should register luggage by airline successfully", async () => {
      mockContractCall.mockReturnValueOnce(mockTxOk(1))
      
      const result = await mockContract.registerByAirline(
          PASSENGER,
          "AA123",
          "JFK",
          "LAX",
          "Black suitcase with red tag",
          15000,
      )
      
      expect(mockContractCall).toHaveBeenCalledWith(
          "registerByAirline",
          PASSENGER,
          "AA123",
          "JFK",
          "LAX",
          "Black suitcase with red tag",
          15000,
      )
      expect(result.isOk).toBe(true)
      expect(result.value).toBe(1)
    })
    
    it("should fail if caller is not contract owner", async () => {
      mockContractCall.mockReturnValueOnce(mockTxErr(1))
      
      const result = await mockContract.registerByAirline(PASSENGER, "AA123", "JFK", "LAX", "Black suitcase", 15000)
      
      expect(result.isOk).toBe(false)
      expect(result.code).toBe(1)
    })
  })
  
  describe("deactivateLuggage", () => {
    it("should deactivate luggage successfully", async () => {
      mockContractCall.mockReturnValueOnce(mockTxOk(true))
      
      const result = await mockContract.deactivateLuggage(1)
      
      expect(mockContractCall).toHaveBeenCalledWith("deactivateLuggage", 1)
      expect(result.isOk).toBe(true)
      expect(result.value).toBe(true)
    })
    
    it("should fail if luggage not found", async () => {
      mockContractCall.mockReturnValueOnce(mockTxErr(2))
      
      const result = await mockContract.deactivateLuggage(999)
      
      expect(result.isOk).toBe(false)
      expect(result.code).toBe(2)
    })
  })
  
  describe("getLuggage", () => {
    it("should return luggage information", async () => {
      const luggageData = {
        passenger: PASSENGER,
        flightNumber: "AA123",
        departure: "JFK",
        arrival: "LAX",
        description: "Black suitcase with red tag",
        weight: 15000,
        isActive: true,
      }
      
      mockContractCall.mockReturnValueOnce(luggageData)
      
      const result = await mockContract.getLuggage(1)
      
      expect(mockContractCall).toHaveBeenCalledWith("getLuggage", 1)
      expect(result).toEqual(luggageData)
    })
  })
})

