import { describe, it, expect, beforeEach, vi } from "vitest"

// Mock contract calls
const mockContractCall = vi.fn()
const mockTxOk = (value) => ({ value, isOk: true })
const mockTxErr = (code) => ({ code, isOk: false })

// Mock contract
const mockContract = {
  recordLocation: (...args) => mockContractCall("recordLocation", ...args),
  getLocationUpdate: (...args) => mockContractCall("getLocationUpdate", ...args),
  getCurrentLocation: (...args) => mockContractCall("getCurrentLocation", ...args),
  setContractOwner: (...args) => mockContractCall("setContractOwner", ...args),
}

// Mock principals
const OWNER = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
const SCANNER = "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"

describe("Location Tracking Contract", () => {
  beforeEach(() => {
    mockContractCall.mockReset()
  })
  
  describe("recordLocation", () => {
    it("should record a location update successfully", async () => {
      mockContractCall.mockReturnValueOnce(mockTxOk(1))
      
      const result = await mockContract.recordLocation(1, "JFK", "check-in", true, "Bag scanned at check-in counter")
      
      expect(mockContractCall).toHaveBeenCalledWith(
          "recordLocation",
          1,
          "JFK",
          "check-in",
          true,
          "Bag scanned at check-in counter",
      )
      expect(result.isOk).toBe(true)
      expect(result.value).toBe(1)
    })
    
    it("should fail if caller is not contract owner", async () => {
      mockContractCall.mockReturnValueOnce(mockTxErr(1))
      
      const result = await mockContract.recordLocation(1, "JFK", "check-in", true, "notes")
      
      expect(result.isOk).toBe(false)
      expect(result.code).toBe(1)
    })
  })
  
  describe("getCurrentLocation", () => {
    it("should return current location information", async () => {
      const locationData = {
        airport: "JFK",
        zone: "security",
        isOnTrack: true,
      }
      
      mockContractCall.mockReturnValueOnce(locationData)
      
      const result = await mockContract.getCurrentLocation(1)
      
      expect(mockContractCall).toHaveBeenCalledWith("getCurrentLocation", 1)
      expect(result).toEqual(locationData)
    })
  })
})

